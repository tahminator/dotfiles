local colors = require("colors")
local icon_map = require("icon_map")

---@type RiftAPI
local rift = require("riftapi")

local front_app = SBAR.add("item", "front_app", {
	position = "left",
	icon = {
		string = ":default:",
		font = {
			family = "sketchybar-app-font",
			style = "Regular",
			size = 14.0,
		},
	},
	label = {
		string = "...",
		font = {
			family = "Monocraft Nerd Font",
			style = "Semibold",
			size = 12.0,
		},
		y_offset = 1,
	},
})

local function set_app(app_name)
	if type(app_name) == "string" and app_name ~= "" then
		front_app:set({
			label = { string = app_name },
			icon = { string = icon_map[app_name] or ":default:" },
		})
	end
end

-- sketchybar fires this natively when the frontmost app changes
front_app:subscribe("front_app_switched", function(env)
	set_app(env.INFO)
end)

-- initial state: pull from the active workspace's first window
local ws_list, _ = rift.query.workspaces()
if ws_list then
	for _, ws in ipairs(ws_list) do
		if ws.is_active and ws.windows and ws.windows[1] then
			set_app(ws.windows[1].app_name)
			break
		end
	end
end

return front_app
