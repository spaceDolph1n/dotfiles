return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- Removed nvim-treesitter dependency. Neovim 0.10+ handles rendering
		-- natively without requiring the nvim-treesitter plugin runtime.
		dependencies = { "echasnovski/mini.icons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			ft = { "markdown", "codecompanion", "mdx" },
		},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		---@module 'obsidian'
		---@type obsidian.config
		opts = {
			-- Fixes legacy command deprecation warning
			legacy_commands = false,
			workspaces = {
				{
					name = "second brain",
					path = "~/.sb/second-brain/",
				},
			},
			-- Removed deprecated 'completion' block.
			-- obsidian-ls (built-in LSP) now handles completion automatically via blink.cmp
			picker = {
				name = "snacks.pick",
			},
			ui = { enable = false },
		},
	},
}
