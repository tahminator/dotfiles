local colors = require("colors")
local font = require("font")

-- Default values applied to all items
-- For a full list of all available item properties see:
-- https://felixkratz.github.io/SketchyBar/config/items

SBAR.default({
	icon = {
		font = font.text,
		color = colors.muted,
		padding_left = 8,
		padding_right = 6,
	},
	label = {
		font = font.text,
		color = colors.fg,
		padding_left = 0,
		padding_right = 8,
	},
	background = {
		color = colors.transparent,
		corner_radius = 8,
		height = 26,
	},
	padding_left = 3,
	padding_right = 3,
})
