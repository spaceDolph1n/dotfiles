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
			-- Note *creation* is unbound on purpose: notes are made in mini.files,
			-- so note_id_func never runs and cannot impose timestamp IDs over the
			-- kebab-case convention. Finding notes is the snacks pickers' job.
			{
				"<leader>ki",
				"<cmd>Obsidian link<cr>",
				mode = { "n", "v" },
				ft = "markdown",
				desc = "Link word to existing note",
			},
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
			-- render-markdown.nvim does all the rendering; running obsidian.nvim's
			-- UI as well double-conceals the same syntax.
			ui = { enable = false },
			-- Written on save for any vault note, which is what gives files made in
			-- mini.files a header. Matches the vault schema; the builtin only emits
			-- id/aliases/tags.
			frontmatter = {
				enabled = true,
				func = function(note)
					local out = {
						id = note.id,
						aliases = note.aliases,
						tags = note.tags,
					}
					-- Carry over fields obsidian.nvim doesn't know about --
					-- `created`, `found-in`, and anything added later.
					if note.metadata and not vim.tbl_isempty(note.metadata) then
						for key, value in pairs(note.metadata) do
							out[key] = value
						end
					end
					-- Stamped once, on the first write; never rewritten after.
					out.created = out.created or os.date("%Y-%m-%d")
					return out
				end,
				sort = { "id", "aliases", "tags", "created", "found-in" },
			},
		},
	},
}
