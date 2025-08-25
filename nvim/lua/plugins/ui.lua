return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,
		opts = {
			preset = "helix",
			win = {
				padding = { 2, 2 },
			},
			spec = {
				{ "<leader>a", group = "AI" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Go", icon = { icon = "⏩" } },
				{ "<leader>l", group = "Git" },
				{ "<leader>o", group = "Git PRs" },
				{ "<leader>s", group = "Window" },
				{ "<leader>t", group = "Tools", icon = { icon = "🔧" } },
				{ "<leader>ts", group = "Spectre", icon = { icon = "🔍" } },
				{ "<leader>u", group = "UI" },
				{ "<leader>/", desc = "Terminal", icon = { icon = "" } },
			},
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- You can enable a preset for easier configuration
			presets = {
				bottom_search = false, -- Use a classic bottom cmdline for search
				command_palette = true, -- Position the cmdline and popupmenu together
				long_message_to_split = true, -- Long messages will be sent to a split
				inc_rename = false, -- Enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- Add a border to hover docs and signature help
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"chrisgrieser/nvim-origami",
		event = "VeryLazy",
		opts = {}, -- needed even when using default config

		-- recommended: disable vim's auto-folding
		init = function()
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
	},
}
