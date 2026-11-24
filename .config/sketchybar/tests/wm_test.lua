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
				{ index = 0, name = "a", is_active = true, is_focused = false, windows = {} },
				{ index = 30, is_active = true, is_focused = true, windows = {
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
	equal(state.workspaces[1].label, "A")
	equal(state.workspaces[1].focused, false)
	equal(state.workspaces[2].focused, true)
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
	return { { name = "Mail", is_frontmost = false }, { name = "Finder", is_frontmost = true } }
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
-- Late geometry replies must not move a newer workspace selection.
requests = {}
local function focused(id)
	render({ front_app = "", workspaces = {
		{ id = "named", label = "A", focused = id == "named", apps = { "Finder" } },
		{ id = "empty", label = "B", focused = id == "empty", apps = { "Mail" } },
	} })
end
focused("empty")
equal(added["space.empty"].props.background.color, require("colors").transparent)
equal(added["space.named"].props.background.color, require("colors").selection)
focused("empty")
equal(added["space.empty"].props.background.color, require("colors").transparent)
focused("named")
focused("empty")
equal(#requests, 2)
local offsets, animation_item = {}, "empty"
SBAR.animate = function(_, _, callback)
	offsets[#offsets + 1] = added["space." .. animation_item].props.background.x_offset
	callback()
end
local function rect(x, offset)
	return {
		bounding_rects = { ["display-1"] = { origin = { x, 0 }, size = { 32, 36 } } },
		geometry = { background = { x_offset = offset or 0 }, padding_left = 3, padding_right = 3 },
	}
end
requests[2].callback(rect(100, 15))
requests[3].callback(rect(160))
equal(offsets[1], -45)
requests[1].callback(rect(100))
equal(#offsets, 1)
equal(added["space.empty"].props.background.x_offset, 0)
focused("named")
animation_item = "named"
requests[4].callback(rect(-9999))
requests[5].callback(rect(160))
equal(added["space.named"].props.background.x_offset, 0)

local function empty_state(active, occupied)
	render({ front_app = "", workspaces = {
		{ id = "named", label = "A", focused = active == "named", apps = occupied == "named" and { "Finder" } or {} },
		{ id = "empty", label = "B", focused = active == "empty", apps = occupied == "empty" and { "Mail" } or {} },
	} })
end

-- Keep an empty source until its selection has slid, then collapse it.
empty_state("named")
requests = {}
empty_state("empty")
equal(added["space.named"].props.drawing, true)
requests[1].callback(rect(100))
equal(added["space.named"].props.drawing, true)
empty_state("empty")
equal(added["space.named"].props.drawing, true)
animation_item = "empty"
requests[2].callback(rect(138))
equal(offsets[#offsets], -38)
equal(added["space.named"].props.drawing, true)
requests[3].callback()
equal(added["space.named"].props.width, 0)
requests[4].callback()
equal(added["space.named"].props.drawing, false)
equal(added["space.named"].props.width, "dynamic")

requests = {}
empty_state("named", "named")
equal(added["space.empty"].props.drawing, true)
requests[1].callback(rect(130))
equal(added["space.empty"].props.drawing, true)
animation_item = "named"
requests[2].callback(rect(100))
equal(offsets[#offsets], 30)
requests[3].callback()
requests[4].callback()
equal(added["space.empty"].props.drawing, false)

-- A late destination query must not override a newer focus.
requests = {}
empty_state("empty")
requests[1].callback(rect(100))
empty_state("named", "named")
local count = #offsets
requests[2].callback(rect(130))
equal(#offsets, count)
equal(added["space.named"].props.background.color, require("colors").selection)

-- Refocusing a retiring workspace cancels its delayed collapse.
requests = {}
empty_state("empty")
requests[1].callback(rect(100))
animation_item = "empty"
requests[2].callback(rect(138))
empty_state("named", "named")
local request_count = #requests
requests[3].callback()
equal(#requests, request_count)
equal(added["space.named"].props.drawing, true)
equal(added["space.named"].props.width, "dynamic")
render({ front_app = "", workspaces = {} })
assert(removed["space.named"] and removed["space.empty"])
equal(added.front_app.props.label.string, "")
print("All WM tests passed")
