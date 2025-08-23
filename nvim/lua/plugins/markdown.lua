return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			ft = { "markdown", "codecompanion" },
			-- render_modes = true, -- Render in ALL modes
			completions = { blink = { enabled = true } },
		},
	},
	-- {
	-- 	"epwalsh/obsidian.nvim",
	-- 	version = "*", -- recommended, use latest release instead of latest commit
	-- 	lazy = true,
	-- 	ft = "markdown",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- 	opts = {
	-- 		workspaces = {
	-- 			{
	-- 				name = "second brain",
	-- 				path = "/Users/tiagorodrigues/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain",
	-- 			},
	-- 		},
	-- 		ui = { enable = false },
	-- 	},
	-- },
}
