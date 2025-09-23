local wezterm = require("wezterm")
return {
	enable_tab_bar = false,
	font_size = 12.0,
	font = wezterm.font("JetBrains Mono"),
	-- macos_window_background_blur = 30,
	window_background_opacity = 1,
	window_decorations = "RESIZE",

	keys = {
		{
			key = "'",
			mods = "CTRL",
			action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
		},
		{ key = "Enter", mods = "OPT", action = wezterm.action.DisableDefaultAssignment },
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
	force_reverse_video_cursor = true,
	colors = {
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
	},
}
