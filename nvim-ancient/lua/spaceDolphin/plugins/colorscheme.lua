return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Make sure to load this before all the other start plugins
		config = function()
			-- Custom colors for Catppuccin Mocha (optional)
			local mocha_config = {
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				transparent_background = true, -- disables setting the background color.
				term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
				dim_inactive = {
					enabled = true, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.15, -- percentage of the shade to apply to the inactive window
				},
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
				},
			}
			-- Set up Catppuccin theme with custom configuration
			require("catppuccin").setup(mocha_config)
			-- Load the colorscheme
			vim.cmd([[colorscheme catppuccin]])
		end,
	},
}

-- return {
-- 	"rjshkhr/shadow.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		vim.opt.termguicolors = true
-- 		vim.cmd.colorscheme("shadow")
-- 	end,
-- }
