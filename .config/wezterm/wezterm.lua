local wezterm = require("wezterm") --[[@as Wezterm]]
local mux = wezterm.mux
local gui = wezterm.gui

local BG_BLUR = 0
local BG_OPACITY = 0.9

local config = {
	font = wezterm.font("SF Mono"),
	font_size = 16,
	line_height = 1.3,
	freetype_load_target = "Light",
	freetype_load_flags = "NO_AUTOHINT",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

	colors = {
		background = "#191919",
		foreground = "#feffff",
		cursor_bg = "#feffff",
		cursor_fg = "#161616",
		selection_bg = "#393939",
		selection_fg = "#000000",
		ansi = {
			"#252525",
			"#dc5e94",
			"#67bb6e",
			"#fbe98a",
			"#5baef8",
			"#ee85b4",
			"#70d7d7",
			"#dde0e5",
		},
		brights = {
			"#393939",
			"#dc5e94",
			"#67bb6e",
			"#fbe98a",
			"#5baef8",
			"#ee85b4",
			"#70d7d7",
			"#feffff",
		},
		compose_cursor = "#b796f8",
	},

	use_fancy_tab_bar = false,
	window_decorations = "RESIZE",
	hide_tab_bar_if_only_one_tab = true,
	window_background_opacity = BG_OPACITY,
	macos_window_background_blur = BG_BLUR,

	front_end = "WebGpu",
	max_fps = 240,
	animation_fps = 240,

	keys = {
		{
			key = "Backspace",
			mods = "CMD",
			action = wezterm.action.SendString("\x15"),
		},
		{
			key = "Backspace",
			mods = "OPT",
			action = wezterm.action.SendString("\x17"),
		},
		{
			key = "LeftArrow",
			mods = "OPT",
			action = wezterm.action.SendKey({
				key = "b",
				mods = "ALT",
			}),
		},
		{
			key = "RightArrow",
			mods = "OPT",
			action = wezterm.action.SendKey({ key = "f", mods = "ALT" }),
		},
		{
			key = "LeftArrow",
			mods = "CMD",
			action = wezterm.action.SendString("\x01"),
		},
		{
			key = "RightArrow",
			mods = "CMD",
			action = wezterm.action.SendString("\x05"),
		},
	},
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "powershell" }
end

wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if window:is_focused() then
		overrides.macos_window_background_blur = BG_BLUR
	else
		overrides.macos_window_background_blur = 20
	end
	window:set_config_overrides(overrides)
end)

-- Fullscreen mode on launch.
wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

return config
