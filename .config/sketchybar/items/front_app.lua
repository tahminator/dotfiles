local icon_map = require("icon_map")
local wm = require("wm")

local front_app = SBAR.add("item", "front_app", {
	position = "left",
	icon = {
		string = ":default:",
		font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
	},
	label = {
		string = "...",
		font = { family = "Monocraft Nerd Font", style = "Semibold", size = 12.0 },
		y_offset = 1,
	},
})

wm.subscribe(function(state)
	front_app:set({
		label = { string = state.front_app },
		icon = { string = icon_map[state.front_app] or ":default:" },
	})
end)

return front_app
