local colors = require("colors")
local font = require("font")

-- Default values applied to all items
-- For a full list of all available item properties see:
-- https://felixkratz.github.io/SketchyBar/config/items

-- Plain text on the bar; one character cell on each side separates items.
SBAR.default({
	icon = {
		font = font.text,
		color = colors.fg,
		padding_left = font.cell,
		padding_right = font.cell,
	},
	label = {
		font = font.text,
		color = colors.fg,
		padding_left = 0,
		padding_right = font.cell,
	},
	background = { drawing = false },
	padding_left = 0,
	padding_right = 0,
})
