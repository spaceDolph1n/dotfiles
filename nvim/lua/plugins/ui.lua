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
				{ "<leader>a", group = "AI", icon = { icon = "🤖" } },
				{ "<leader>d", group = "Debug", icon = { icon = "🐞" } },
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git", icon = { icon = "🌿" } },
				{ "<leader>h", group = "Harpoon", icon = { icon = "🧷" } },
				{ "<leader>k", group = "Knowledge", icon = { icon = "🧠" } },
				{ "<leader>l", group = "LSP", icon = { icon = "⏩" } },
				{ "<leader>r", group = "REST", icon = { icon = "🌐" } },
				{ "<leader>s", group = "Window" },
				{ "<leader>t", group = "Tests", icon = { icon = "🔧" } },
				{ "<leader>u", group = "UI" },
				{ "<leader>x", group = "Tools", icon = { icon = "🔧" } },
				{ "<leader>y", group = "Yank", icon = { icon = "📋" } },
				{ "<leader>/", desc = "Terminal", icon = { icon = "" } },
			},
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	-- noice.nvim removed: it hooked Neovim's message/cmdline internals and
	-- snacks.notifier already owns notifications. nvim-origami removed:
	-- treesitter supplies foldexpr, snacks.statuscolumn draws the fold column.
}
