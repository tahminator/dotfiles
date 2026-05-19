local colors = require("colors")
local icon_map = require("icon_map")

SBAR.add("event", "front_app_changed")

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

local function update_front_app()
	SBAR.exec(
		"aerospace list-windows --focused | awk -F '|' '{gsub(/^ *| *$/, \"\", $2); print $2}'",
		function(app_name)
			if type(app_name) == "string" then
				---@cast app_name string
				local cleaned_name = app_name:gsub("%s+", "")
				if cleaned_name ~= "" then
					local app_icon = icon_map[cleaned_name] or ":default:"

					front_app:set({
						label = { string = cleaned_name },
						icon = { string = app_icon },
					})
				end
			end
		end
	)
end

front_app:subscribe("front_app_changed", update_front_app)

update_front_app()

return front_app
