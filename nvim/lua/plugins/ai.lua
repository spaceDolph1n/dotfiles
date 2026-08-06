-- sidekick.nvim -- keeps Claude in a tmux pane (as before) but stops the
-- copy-paste shuttle: it sends the current file, selection, cursor position and
-- LSP diagnostics as context, and keeps a named session per project that
-- survives closing Neovim.
--
-- Deliberately CLI-only. Copilot's Next Edit Suggestions are disabled: they
-- require the Copilot LSP server, which this config does not install, and the
-- NES keymap would otherwise claim <Tab> away from blink.cmp.
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
