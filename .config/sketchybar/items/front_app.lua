local font = require("font")
local icon_map = require("icon_map")
local wm = require("wm")

local front_app = SBAR.add("item", "front_app", {
	position = "left",
	icon = { string = ":default:", font = font.apps },
	label = { string = "..." },
})

wm.subscribe(function(state)
	front_app:set({
		label = { string = state.front_app },
		icon = { string = icon_map[state.front_app] or ":default:" },
	})
end)

return front_app
