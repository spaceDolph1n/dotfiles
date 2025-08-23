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
