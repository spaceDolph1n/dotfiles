return {
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
			-- { "<leader>a", group = "AI Avante" },
			{ "<leader>c", desc = "AI Chat" },
			-- { "<leader>e", group = "File Explorer" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Go", icon = { icon = "⏩" } },
			-- { "<leader>h", group = "GitSigns" },
			{ "<leader>l", group = "Git" },
			{ "<leader>o", group = "Git PRs" },
			{ "<leader>s", group = "Window management" },
			{ "<leader>t", group = "Tools", icon = { icon = "🔧" } },
			{ "<leader>u", group = "UI" },
			{ "<leader>w", desc = "Save", icon = { icon = "⚡" } },
			{ "<leader>W", desc = "Save all", icon = { icon = "💾" } },
			-- { "<leader>x", group = "Diagnostics Trouble" },
			{ "<leader>/", desc = "Terminal", icon = { icon = "" } },
			{ "<leader>+", desc = "Increment", icon = { icon = "➕" } },
			{ "<leader>-", desc = "Decrement", icon = { icon = "➖" } },
		},
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
}
