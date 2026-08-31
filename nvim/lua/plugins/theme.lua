return {
	{
		-- lotus, dragon, wave
		"rebelot/kanagawa.nvim",
		enabled = false,
		config = function()
			require("kanagawa").setup({
				commentStyle = { italic = true },
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none", -- Transparent line numbers
							},
						},
					},
				},
			})
			vim.cmd("colorscheme kanagawa-dragon")
		end,
	},
	{
		-- ink, canvas
		"thesimonho/kanagawa-paper.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			vim.cmd("colorscheme kanagawa-paper-ink")
		end,
	},
	{
		-- zen, ink, mist, pearl
		"webhooked/kanso.nvim",
		enabled = true,
		lazy = false,
		priority = 1000,
		config = function()
			-- Transparent hands the background back to tmux, which is what makes
			-- window-style dim an inactive nvim pane -- an opaque Normal.bg paints
			-- over it. Costs nothing visually: zenBg0, float.bg and pmenu.bg are all
			-- #090E13, the same colour tmux and wezterm already paint.
			require("kanso").setup({ transparent = true })
			vim.cmd("colorscheme kanso-zen")
		end,
	},
	-- normal, moon, dawn
	{
		"rose-pine/neovim",
		enabled = false,
		name = "rose-pine",
		config = function()
			vim.cmd("colorscheme rose-pine")
		end,
	},
}
