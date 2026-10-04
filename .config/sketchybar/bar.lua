local colors = require("colors")

-- Blurred glass panel with window-like corners around pixel-font content.
SBAR.bar({
	height = 36,
	blur_radius = 30,
	position = "top",
	topmost = "window",
	sticky = true,
	padding_left = 6, -- the spaces bracket absorbs its items' padding; supply the full 6pt edge gap
	padding_right = 3,
	margin = 14,
	y_offset = 8,
	notch_offset = 4,
	corner_radius = 12,
	color = colors.bar,
	border_color = colors.glass,
	border_width = 1,
	notch_width = 0,
	font_smoothing = false,
})
