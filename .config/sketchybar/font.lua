-- Ghostty's font (~/.config/ghostty/config: font-family).
-- ProggyClean draws on a 16px em (128 units/px at 2048 upm), so 16pt maps
-- one font pixel to one point and stays crisp; Ghostty's 18pt does not.
local size = 16.0
-- One character cell: 896/2048 em advance = 7pt at 16pt.
local cell = 7

return {
	text = { family = "ProggyClean Nerd Font", style = "Regular", size = size },
	apps = { family = "sketchybar-app-font", style = "Regular", size = 13.0 },
	cell = cell,
	-- Fixed label.width for `chars` cells; SketchyBar counts the label's
	-- padding_right (one cell, see default.lua) inside that width.
	label_width = function(chars)
		return (chars + 1) * cell
	end,
}
