-- Plain monochrome status line, using the Ghostty theme in
-- ~/.config/ghostty/themes/mono.
return {
	bar = 0xff000000, -- background #000000, opaque
	fg = 0xfffeffff, -- foreground
	-- Status levels for the battery, CPU, and memory readouts.
	red = 0xffdc5e94, -- palette 1
	green = 0xff67bb6e, -- palette 2
	yellow = 0xfffbe98a, -- palette 3
	orange = 0xffff8700, -- palette 208
}
