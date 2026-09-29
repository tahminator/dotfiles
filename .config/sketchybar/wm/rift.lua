local M = {}

local labels = {
	"",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"A",
	"C",
	"D",
	"E",
	"F",
	"G",
	"I",
	"M",
	"O",
	"P",
	"Q",
	"S",
	"T",
	"U",
	"W",
	"Y",
	"Z",
}

---@return WMBackend
function M.new()
	---@type RiftAPI
	local rift = require("riftapi")
	---@type WMBackend
	---@diagnostic disable-next-line: missing-fields
	local backend = {}

	function backend.get_state(callback)
		local workspaces, err = rift.query.workspaces()
		if not workspaces then
			callback(nil, err or "Could not query Rift workspaces")
			return
		end
		---@type WMState
		local state = { workspaces = {}, front_app = "" }
		for _, ws in ipairs(workspaces) do
			local apps = {}
			for _, window in ipairs(ws.windows or {}) do
				if window.app_name and window.app_name ~= "" then
					apps[#apps + 1] = window.app_name
					if ws.is_active and window.is_focused then
						state.front_app = window.app_name
					end
				end
			end
			state.workspaces[#state.workspaces + 1] = {
				id = tostring(ws.index),
				label = labels[ws.index + 1] or tostring(ws.index + 1),
				focused = ws.is_active,
				apps = apps,
			}
		end
		-- An active application's window need not be managed by Rift.
		local applications = rift.query.applications()
		for _, app in ipairs(applications or {}) do
			if app.is_active then
				state.front_app = app.name
				break
			end
		end
		callback(state)
	end

	function backend.focus_workspace(id)
		local index = tonumber(id)
		assert(index and index >= 0 and index % 1 == 0, "Invalid Rift workspace index")
		rift.workspace.switch(index)
	end

	function backend.create_workspace()
		rift.workspace.create()
	end

	function backend.watch(on_change)
		local watcher = SBAR.add("item", "wm.watcher", { drawing = false, updates = true, update_freq = 5 })
		watcher:subscribe({ "front_app_switched", "space_change", "system_woke", "forced", "routine" }, on_change)
		rift.subscribe({ "*" }, on_change)
	end

	return backend
end

return M
