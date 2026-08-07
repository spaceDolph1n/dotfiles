return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		-- Rendering needs the `markdown` + `markdown_inline` parsers, which
		-- core bundles -- no nvim-treesitter dependency required.
		dependencies = { "echasnovski/mini.icons" },
		ft = { "markdown", "mdx" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			-- "codecompanion" dropped along with the AI plugins.
			ft = { "markdown", "mdx" },
		},
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- Links only go one way in the file itself. These make the vault
		-- navigable in both directions from inside Neovim, which is the whole
		-- reason to keep obsidian.nvim now that Obsidian itself is gone.
		keys = {
			{ "<leader>kb", "<cmd>Obsidian backlinks<cr>", ft = "markdown", desc = "Backlinks to this note" },
			{ "<leader>kl", "<cmd>Obsidian links<cr>", ft = "markdown", desc = "Links in this note" },
			-- Turn the word under the cursor (or a visual selection) into a new
			-- note and link to it in one step -- the usual way a concept earns a
			-- note is that you just wrote its name.
			{
				"<leader>kn",
				"<cmd>Obsidian link_new<cr>",
				mode = { "n", "v" },
				ft = "markdown",
				desc = "New note from word/selection",
			},
			{
				"<leader>ki",
				"<cmd>Obsidian link<cr>",
				mode = { "n", "v" },
				ft = "markdown",
				desc = "Link word to existing note",
			},
			{
				"<leader>kx",
				"<cmd>Obsidian extract_note<cr>",
				mode = "v",
				ft = "markdown",
				desc = "Extract selection into a note",
			},
			{ "<leader>ko", "<cmd>Obsidian quick_switch<cr>", desc = "Open note" },
			{ "<leader>ks", "<cmd>Obsidian search<cr>", desc = "Search vault" },
			{ "<leader>kt", "<cmd>Obsidian tags<cr>", ft = "markdown", desc = "Tags" },
			{ "<leader>kc", "<cmd>Obsidian toc<cr>", ft = "markdown", desc = "Table of contents" },
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
