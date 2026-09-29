local M = {}

local function quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

-- Workspace focus is independent of window focus: an empty workspace can
-- still be focused. Never infer either from its window count.
local function normalize(workspaces, focused, windows, front, monitor)
	---@type WMState
	local state = { workspaces = {}, front_app = front[1] and front[1]["app-name"] or "" }
	local by_id = {}
	local focused_id = focused[1] and focused[1].workspace
	for _, row in ipairs(workspaces) do
		local ws = {
			id = row.workspace,
			label = row.workspace,
			focused = row.workspace == focused_id,
			apps = {},
			display = monitor,
		}
		state.workspaces[#state.workspaces + 1] = ws
		by_id[ws.id] = ws
	end
	for _, window in ipairs(windows) do
		local ws = by_id[window.workspace]
		if ws then
			ws.apps[#ws.apps + 1] = window["app-name"]
		end
	end
	return state
end

---@param binary AerospaceBinary
---@param monitor? integer
---@return WMBackend
function M.new(binary, monitor)
	assert(binary == "aerospace" or binary == "flightdeck", "Invalid AeroSpace-compatible binary")
	monitor = monitor or 1
	assert(type(monitor) == "number" and monitor >= 1 and monitor % 1 == 0, "Invalid monitor")

	---@type WMBackend
	---@diagnostic disable-next-line: missing-fields
	local backend = {}

	function backend.get_state(callback)
		-- SbarLua decodes JSON arrays for us. Four queries regardless of the
		-- workspace count; no sentinel output, line parsing, or per-space calls.
		local queries = {
			{ key = "workspaces", args = "list-workspaces --monitor " .. monitor },
			{ key = "focused", args = "list-workspaces --focused" },
			{ key = "windows", args = "list-windows --monitor " .. monitor .. " --format '%{workspace}%{app-name}'" },
			{ key = "front", args = "list-windows --focused --format '%{app-name}'", optional = true },
		}
		local results, pending, failure = {}, #queries, nil
		for _, query in ipairs(queries) do
			SBAR.exec(binary .. " " .. query.args .. " --json", function(out, code)
				local ok = (code == nil or code == 0) and type(out) == "table"
				results[query.key] = ok and out or {}
				-- No focused window is normal on an empty workspace. Its CLI
				-- error/output must not invalidate otherwise valid workspace state.
				if not ok and not query.optional then
					failure = failure or (binary .. " command failed: " .. query.args)
				end
				pending = pending - 1
				if pending == 0 then
					if failure then
						callback(nil, failure)
					else
						callback(normalize(results.workspaces, results.focused, results.windows, results.front, monitor))
					end
				end
			end)
		end
	end

	function backend.focus_workspace(id)
		SBAR.exec(binary .. " workspace " .. quote(id))
	end

	function backend.watch(on_change)
		-- Retain existing hooks for both AeroSpace and its drop-in replacement.
		local events = { "aerospace_workspace_change", "front_app_changed" }
		if binary == "flightdeck" then
			events[#events + 1] = "flightdeck_workspace_change"
		end
		for _, event in ipairs(events) do
			SBAR.add("event", event)
		end
		for _, event in ipairs({ "front_app_switched", "space_change", "system_woke", "forced", "routine" }) do
			events[#events + 1] = event
		end
		local watcher = SBAR.add("item", "wm.watcher", { drawing = false, updates = true, update_freq = 5 })
		watcher:subscribe(events, on_change)
	end

	return backend
end

return M
