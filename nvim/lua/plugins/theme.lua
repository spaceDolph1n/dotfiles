-- `scripts/theme` owns which theme is active; this file owns how each one is
-- configured. Both plugins stay installed so the generator can read either
-- palette off disk -- `lazy` keeps the inactive one from loading.
local active = require("active-theme")

return {
	{
		-- lotus, dragon, wave
		"rebelot/kanagawa.nvim",
		enabled = true,
		lazy = active ~= "kanagawa-dragon",
		config = function()
			require("kanagawa").setup({
				-- Same reason as kanso below: tmux dims an inactive pane by tinting
				-- cells that use the default background, so nvim must not paint its own.
				transparent = true,
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
		lazy = active ~= "kanso",
		priority = 1000,
		config = function()
			-- Transparent hands the background back to tmux, which is what makes
			-- window-style dim an inactive nvim pane -- an opaque Normal.bg paints
			-- over it. Costs nothing visually: zenBg0, float.bg and pmenu.bg are all
			-- #090E13, the same colour tmux and ghostty already paint.
			require("kanso").setup({ transparent = true })
			vim.cmd("colorscheme kanso-zen")
		end,
	},
	-- normal, moon, dawn
	{
		"rose-pine/neovim",
		enabled = true,
		name = "rose-pine",
		lazy = active ~= "rose-pine",
		priority = 1000,
		config = function()
			-- Transparent for the same reason as the two above: tmux dims an
			-- inactive pane by tinting cells that use the default background.
			--
			-- `base` is overridden away from rose-pine's own #191724 because this
			-- variant is the near-black one. scripts/theme-palette applies the same
			-- override, so nvim and every generated surface agree.
			require("rose-pine").setup({
				styles = { transparency = true, italic = false },
				palette = { main = { base = "#090b10" } },
			})
			vim.cmd("colorscheme rose-pine")
		end,
	},
}
