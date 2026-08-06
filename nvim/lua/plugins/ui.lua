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
				{ "<leader>w", hidden = true },
				{ "<leader>W", hidden = true },
				{ "<leader>q", hidden = true },
				{ "<leader>Q", hidden = true },
				{ "<leader>d", group = "Debug", icon = { icon = "🐞" } },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git", icon = { icon = "🌿" } },
				{ "<leader>l", group = "LSP", icon = { icon = "⏩" } },
				{ "<leader>s", group = "Window" },
				{ "<leader>t", group = "Tests", icon = { icon = "🔧" } },
				{ "<leader>u", group = "UI" },
				{ "<leader>x", group = "Tools", icon = { icon = "🔧" } },
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
				-- Render LSP markdown (hover, signature help) with treesitter.
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					-- ["cmp.entry.get_documentation"] dropped: that override is
					-- for hrsh7th/nvim-cmp, which this config does not use.
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
