-- sidekick.nvim -- Claude in a tmux pane, sent the current file, selection and
-- diagnostics as context, with a named session per project. CLI-only: Copilot
-- NES needs an LSP server this config lacks, and would claim <Tab> from blink.
return {
	"folke/sidekick.nvim",
	dependencies = { "folke/snacks.nvim" },
	opts = {
		nes = { enabled = false },
		cli = {
			mux = {
				-- Sessions live in tmux, so they persist across Neovim restarts
				-- and are still reachable from a normal tmux pane.
				backend = "tmux",
				enabled = true,
			},
		},
	},
	keys = {
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Toggle AI CLI",
		},
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({ name = "claude", focus = true })
			end,
			desc = "Claude",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Ask with Prompt",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").send({ selection = true })
			end,
			mode = "x",
			desc = "Send Selection",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").send({ msg = "{diagnostics}" })
			end,
			desc = "Send Diagnostics",
		},
	},
}
