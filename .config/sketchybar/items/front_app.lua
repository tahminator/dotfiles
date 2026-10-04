local colors = require("colors")
local font = require("font")
local icon_map = require("icon_map")
local wm = require("wm")

local front_app = SBAR.add("item", "front_app", {
	position = "left",
	padding_left = 6, -- the spaces bracket absorbs its items' padding; supply the full 6pt gap
	icon = {
		string = ":default:",
		font = font.apps,
		color = colors.fg,
	},
	label = { string = "..." },
})

wm.subscribe(function(state)
	front_app:set({
		label = { string = state.front_app },
		icon = { string = icon_map[state.front_app] or ":default:" },
	})
end)

return front_app
