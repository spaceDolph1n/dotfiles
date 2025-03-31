return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- See Configuration section for options
		},
		-- See Commands section for default commands if you want to lazy load on them
		vim.keymap.set({ "n", "v" }, "<leader>ac", function()
			if vim.fn.mode() == "v" then
				require("CopilotChat").toggle({ selection = require("CopilotChat.select").visual })
			else
				require("CopilotChat").toggle()
			end
		end, { desc = "Chat" }),
		vim.keymap.set("n", "<leader>am", "<cmd>CopilotChatModels<cr>", { desc = "Models" }),
	},
}
