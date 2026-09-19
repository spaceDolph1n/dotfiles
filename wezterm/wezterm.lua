local wezterm = require("wezterm")
local act = wezterm.action

-- `config_builder` gives clearer error messages with the offending field name
-- instead of a bare "invalid config" on a typo.
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- Colours (Kanso) -- fixed. Colourscheme swapping happens in Neovim, not here.
--------------------------------------------------------------------------------
config.colors = {
	foreground = "#e0def4",
	background = "#090b10",

	cursor_bg = "#090b10",
	cursor_fg = "#e0def4",
	cursor_border = "#e0def4",

	selection_fg = "#e0def4",
	selection_bg = "#26233a",

	scrollbar_thumb = "#26233a",
	split = "#26233a",

	-- The 16 ANSI slots, and the only definition of them on this machine: tmux
	-- pane borders, starship, fzf and eza all resolve colour names through here.
	ansi = {
		"#26233a",
		"#eb6f92",
		"#31748f",
		"#f6c177",
		"#9ccfd8",
		"#c4a7e7",
		"#ebbcba",
		"#e0def4",
	},
	brights = {
		"#6e6a86",
		"#eb6f92",
		"#31748f",
		"#f6c177",
		"#9ccfd8",
		"#c4a7e7",
		"#ebbcba",
		"#e0def4",
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
-- top is deliberately larger than left/right: it is the gap above the tmux
-- status bar, and tmux itself can only pad in whole rows (~17px at this font
-- size), which is too much. Pixels are the only way to get a fraction of a
-- row, so the gap above the window names is tuned here, not in tmux.conf.
-- 8 is the baseline, so top = 8 + however much of a 17px row you want.
config.window_padding = { left = 8, right = 8, top = 24, bottom = 8 }
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

	-- Select-to-copy, mirroring the tmux binding so the behaviour is the same
	-- with or without tmux on top.
	--
	-- WezTerm's default here is CompleteSelection("PrimarySelection"), which does
	-- nothing on macOS -- there is no primary selection -- so a bare WezTerm
	-- window silently dropped the selection. Matters rarely, since tmux is almost
	-- always running and intercepts the mouse first, but "almost" is why this
	-- exists.
	--
	-- ClipboardAndPrimarySelection, not Clipboard, so the same config still does
	-- the right thing on Linux.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},

	-- Double/triple-click select word/line, then copy the same way.
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
}

return config
