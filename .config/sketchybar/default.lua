local colors = require("colors")
local font = require("font")

-- Default values applied to all items
-- For a full list of all available item properties see:
-- https://felixkratz.github.io/SketchyBar/config/items

SBAR.default({
	icon = {
		font = font.text,
		color = colors.muted,
		padding_left = font.cell,
		padding_right = font.cell,
	},
	label = {
		font = font.text,
		color = colors.fg,
		padding_left = 0,
		padding_right = font.cell,
	},
	-- Glass pill; 6pt inset and radius keep it concentric with the bar corners.
	background = {
		color = colors.glass,
		corner_radius = 6,
		height = 24,
	},
	padding_left = 3,
	padding_right = 3,
})
