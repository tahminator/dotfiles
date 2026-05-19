local colors = require("colors")

SBAR.bar({
	height = 40,
	blur_radius = 40,
	position = "top",
	topmost = "window",
	sticky = true,
	padding_left = 10,
	padding_right = 10,
	margin = 14,
	y_offset = 8,
	notch_offset = 4,
	corner_radius = 20,
	color = colors.bar.bg,
	border_color = colors.bar.border,
	border_width = 1,
	notch_width = 0,
})
