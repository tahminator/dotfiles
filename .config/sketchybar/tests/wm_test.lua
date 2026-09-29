-- Run from ~/.config/sketchybar: lua tests/wm_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local function equal(actual, expected)
	assert(actual == expected, string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end

local commands, requests, subscriptions, added, removed = {}, {}, {}, {}, {}
SBAR = {
	exec = function(command, callback)
		commands[#commands + 1] = command
		if callback then
			requests[#requests + 1] = { command = command, callback = callback }
		end
	end,
	add = function(kind, name, props)
		local item = { name = name, props = props or {}, kind = kind }
		function item:set(update)
			for key, value in pairs(update) do self.props[key] = value end
		end
		function item:subscribe(events, callback)
			subscriptions[name] = { events = events, callback = callback }
		end
		added[name] = item
		return item
	end,
	animate = function(_, _, callback) callback() end,
	remove = function(name) removed[name] = true end,
}

local aerospace = require("wm.aerospace")
assert(not pcall(aerospace.new, "bad;binary"))
assert(not pcall(aerospace.new, "aerospace", 1.5))
for _, binary in ipairs({ "aerospace", "flightdeck" }) do
	requests = {}
	local backend = aerospace.new(binary, 1)
	local result, calls = nil, 0
	backend.get_state(function(state, err)
		assert(not err)
		result = state
		calls = calls + 1
	end)
	equal(requests[1].command, binary .. " list-workspaces --monitor 1 --json")
	equal(#requests, 4)
	-- Queries may finish in any order; workspace order remains stable.
	requests[4].callback({ { ["app-name"] = "Google Chrome" } }, 0)
	requests[3].callback({
		{ workspace = "O'Brien", ["app-name"] = "Google Chrome" },
		{ workspace = "O'Brien", ["app-name"] = "Google Chrome" },
	}, 0)
	requests[1].callback({ { workspace = "1" }, { workspace = "O'Brien" } }, 0)
	equal(calls, 0)
	requests[2].callback({ { workspace = "O'Brien" } }, 0)
	equal(calls, 1)
	equal(result.front_app, "Google Chrome")
	equal(result.workspaces[1].id, "1")
	equal(result.workspaces[1].focused, false)
	equal(result.workspaces[2].focused, true)
	backend.focus_workspace("O'Brien")
	equal(commands[#commands], binary .. " workspace 'O'\\''Brien'")
	backend.watch(function() end)
	assert(added.aerospace_workspace_change)
	if binary == "flightdeck" then assert(added.flightdeck_workspace_change) end
end

requests = {}
local errors = 0
local backend = aerospace.new("aerospace")
backend.get_state(function(state, err)
	assert(not state and err)
	errors = errors + 1
end)
requests[1].callback("", 127)
requests[2].callback({}, 0)
requests[3].callback({}, 0)
requests[4].callback("", 127)
equal(errors, 1)

-- Regression: empty focused space -> new window -> last window closed.
-- Missing focus can be an empty array or a nonzero CLI error with output.
for _, front in ipairs({
	{ output = "No window is focused", code = 1, occupied = false },
	{ output = { { ["app-name"] = "Ghostty" } }, code = 0, occupied = true },
	{ output = "No window is focused", code = 2, occupied = false },
	{ output = {}, code = 0, occupied = false },
}) do
	requests = {}
	local calls = 0
	backend.get_state(function(state, err)
		assert(state and not err)
		calls = calls + 1
		equal(state.workspaces[1].focused, true)
		equal(#state.workspaces[1].apps, front.occupied and 1 or 0)
		equal(state.front_app, front.occupied and "Ghostty" or "")
	end)
	requests[1].callback({ { workspace = "1" } }, 0)
	requests[2].callback({ { workspace = "1" } }, 0)
	requests[3].callback(front.occupied and { { workspace = "1", ["app-name"] = "Ghostty" } } or {}, 0)
	requests[4].callback(front.output, front.code)
	equal(calls, 1)
end

requests = {}
backend.get_state(function(state, err)
	assert(not state and err)
	errors = errors + 1
end)
requests[1].callback({ { workspace = "1" } }, 0)
requests[2].callback({ { workspace = "1" } }, 0)
requests[3].callback("query failed", 1)
requests[4].callback({}, 0)
equal(errors, 2)

-- Rift remains lazy and maps actual focus rather than the first window.
local switched, created, watching
package.loaded.riftapi = {
	query = {
		workspaces = function()
			return {
				{ index = 0, is_active = false, windows = {} },
				{ index = 30, is_active = true, windows = {
					{ app_name = "Mail", is_focused = false },
					{ app_name = "Google Chrome", is_focused = true },
				} },
			}
		end,
		applications = function() return {} end,
	},
	workspace = {
		switch = function(index) switched = index end,
		create = function() created = true end,
	},
	subscribe = function(_, callback) watching = callback end,
}
local rift = require("wm.rift").new()
rift.get_state(function(state)
	equal(state.front_app, "Google Chrome")
	equal(state.workspaces[2].id, "30")
	equal(state.workspaces[2].label, "31")
end)
rift.focus_workspace("30")
equal(switched, 30)
rift.create_workspace()
assert(created)
rift.watch(function() end)
assert(watching)
package.loaded.riftapi.query.applications = function()
	return { { name = "Finder", is_active = true } }
end
rift.get_state(function(state) equal(state.front_app, "Finder") end)

-- Controller serializes requests, coalesces invalidations, caches snapshots,
-- and preserves the previous rendered state on failure.
local callbacks, watches, notifications = {}, 0, 0
local focus, create_count = nil, 0
local controller = require("wm.controller").new({
	get_state = function(callback) callbacks[#callbacks + 1] = callback end,
	watch = function() watches = watches + 1 end,
	focus_workspace = function(id) focus = id end,
	create_workspace = function() create_count = create_count + 1 end,
})
controller.subscribe(function() notifications = notifications + 1 end)
controller.start()
controller.start()
equal(watches, 1)
controller.refresh()
controller.refresh()
equal(#callbacks, 1)
callbacks[1]({ workspaces = {}, front_app = "stale" })
equal(notifications, 0)
equal(#callbacks, 2)
callbacks[2]({ workspaces = {}, front_app = "Finder" })
equal(notifications, 1)
controller.subscribe(function(state) equal(state.front_app, "Finder") end)
controller.refresh()
callbacks[3](nil, "expected test failure")
equal(notifications, 1)
controller.activate_workspace("1", "left")
equal(focus, "1")
controller.activate_workspace("1", "right")
equal(create_count, 1)
assert(not pcall(require("wm.controller").new, {}))

-- Both UI items consume only the common contract.
local listeners = {}
package.loaded.wm = {
	subscribe = function(callback) listeners[#listeners + 1] = callback end,
	activate_workspace = function(id, button) focus = id .. ":" .. button end,
}
require("items.spaces")
require("items.front_app")
local function render(state)
	for _, listener in ipairs(listeners) do listener(state) end
end
render({ front_app = "Google Chrome", workspaces = {
	{ id = "named", label = "A", focused = true, apps = { "Google Chrome", "Google Chrome" } },
	{ id = "empty", label = "B", focused = false, apps = {} },
} })
equal(added["space.named"].kind, "item")
equal(added["space.named"].props.drawing, true)
equal(added["space.empty"].props.drawing, false)
equal(added.front_app.props.label.string, "Google Chrome")
equal(added["space.named"].props.label.string, " " .. require("icon_map")["Google Chrome"])
subscriptions["space.named"].callback({ BUTTON = "right" })
equal(focus, "named:right")
-- Closing the last window must clear icons without hiding the active space.
render({ front_app = "", workspaces = {
	{ id = "named", label = "A", focused = true, apps = {} },
	{ id = "empty", label = "B", focused = false, apps = {} },
} })
equal(added["space.named"].props.drawing, true)
equal(added["space.named"].props.label.string, " —")
equal(added["space.empty"].props.drawing, false)
render({ front_app = "", workspaces = {} })
assert(removed["space.named"] and removed["space.empty"])
equal(added.front_app.props.label.string, "")
print("All WM tests passed")
