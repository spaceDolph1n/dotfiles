return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"olimorris/openai.nvim",
	},
	config = function()
		require("codecompanion").setup({
			display = {
				diff = {
					provider = "mini_diff",
				},
			},
			strategies = {
				chat = { adapter = "qwen" },
				inline = { adapter = "qwen" },
			},
			adapters = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = "cmd:op read op://personal/OpenAI/notes --no-newline",
						},
						schema = {
							model = {
								default = "gpt-4o-mini",
							},
						},
					})
				end,
				qwen = function()
					return require("codecompanion.adapters").extend("ollama", {
						name = "qwen",
						schema = {
							model = {
								default = "qwen2.5-coder:14b",
							},
						},
						num_ctx = {
							default = 16384,
						},
					})
				end,
			},
		})
		vim.keymap.set(
			"n",
			"<leader>c",
			"<cmd>CodeCompanionChat Toggle<CR>",
			{ noremap = true, silent = true, desc = "AI Chat" }
		)
	end,
}
