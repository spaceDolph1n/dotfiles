return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" }, -- if you use standalone mini plugins
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			ft = { "markdown", "codecompanion", "mdx" },
			-- completions = { blink = { enabled = true } },
		},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		ft = "markdown",
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",
			"saghen/blink.cmp",
		},
		---@module 'obsidian'
		---@type obsidian.config
		opts = {
			workspaces = {
				{
					name = "second brain",
					path = "/Users/tiagorodrigues/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain",
				},
			},
			completion = {
				nvim_cmp = false,
				blink = true,
				min_chars = 1,
			},
			picker = {
				name = "snacks.pick",
			},
			ui = { enable = false },
		},
	},
}
