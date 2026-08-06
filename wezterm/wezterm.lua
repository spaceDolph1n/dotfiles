local wezterm = require("wezterm")
local act = wezterm.action

-- `config_builder` gives clearer error messages with the offending field name
-- instead of a bare "invalid config" on a typo.
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- Colours (Kanso) -- fixed. Colourscheme swapping happens in Neovim, not here.
--------------------------------------------------------------------------------
config.colors = {
	foreground = "#C5C9C7",
	background = "#090E13",

	cursor_bg = "#090E13",
	cursor_fg = "#C5C9C7",
	cursor_border = "#C5C9C7",

	selection_fg = "#C5C9C7",
	selection_bg = "#22262D",

	scrollbar_thumb = "#22262D",
	split = "#22262D",

	ansi = {
		"#090E13",
		"#C4746E",
		"#8A9A7B",
		"#C4B28A",
		"#8BA4B0",
		"#A292A3",
		"#8EA4A2",
		"#A4A7A4",
	},
	brights = {
		"#A4A7A4",
		"#E46876",
		"#87A987",
		"#E6C384",
		"#7FB4CA",
		"#938AA9",
		"#7AA89F",
		"#C5C9C7",
	},
}

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Regular" },
	-- Explicit fallback so glyphs from mini.icons / lualine resolve to a real
	-- Nerd Font rather than whatever the OS picks.
	"Symbols Nerd Font Mono",
	"Apple Color Emoji",
})
config.font_size = 12.5
config.line_height = 1.05

-- tmux draws the tabs; wezterm's own tab bar would be a second row of them.
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.window_padding = { left = 8, right = 8, top = 8, bottom = 0 }
config.force_reverse_video_cursor = true
config.adjust_window_size_when_changing_font_size = false

--------------------------------------------------------------------------------
-- Behaviour
--------------------------------------------------------------------------------
config.audible_bell = "Disabled"
-- tmux keeps its own 1M-line history; this is the fallback for bare shells.
config.scrollback_lines = 20000
config.window_close_confirmation = "NeverPrompt"
config.check_for_updates = false
-- Only relevant on a 120Hz display, but harmless elsewhere.
config.max_fps = 120

config.keys = {
	{ key = "'", mods = "CTRL", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "Enter", mods = "OPT", action = act.DisableDefaultAssignment },
}

config.mouse_bindings = {
	-- Ctrl-click opens the link under the cursor.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

return config
