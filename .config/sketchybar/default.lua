local colors = require("colors")

-- Default values applied to all items
-- For a full list of all available item properties see:
-- https://felixkratz.github.io/SketchyBar/config/items

SBAR.default({
	icon = {
		font = {
			family = "Monocraft Nerd Font",
			style = "Semibold",
			size = 12.0,
		},
		color = colors.legacy.accent,
		padding_left = 6,
		padding_right = 3,
	},
	label = {
		font = {
			family = "Monocraft Nerd Font",
			style = "Semibold",
			size = 12.0,
		},
		color = colors.legacy.accent,
		padding_left = 3,
		padding_right = 6,
	},
	background = {
		color = colors.bar.secondary,
		corner_radius = 10,
		height = 25,
	},
	padding_left = 2,
	padding_right = 2,
})
