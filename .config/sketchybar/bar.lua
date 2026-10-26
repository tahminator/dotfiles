local colors = require("colors")

-- Solid edge-to-edge status line. 38pt is the built-in display's notch band
-- (NSScreen safeAreaInsets.top), where AeroSpace windows start; keep it in
-- sync with gaps.outer.top in ~/.config/aerospace/aerospace.toml.
SBAR.bar({
	height = 38,
	position = "top",
	topmost = "window",
	sticky = true,
	padding_left = 0,
	padding_right = 0,
	margin = 0,
	y_offset = 0,
	notch_offset = 0,
	corner_radius = 0,
	blur_radius = 0,
	border_width = 0,
	color = colors.bar,
	notch_width = 0,
	font_smoothing = false,
})
