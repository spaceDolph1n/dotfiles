return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		require("mini.hipatterns").setup({
			highlighters = {
				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			},
		})
		require("mini.icons").setup()
		require("mini.ai").setup()
		require("mini.diff").setup()
		require("mini.surround").setup()
		require("mini.pairs").setup()
		require("mini.comment").setup()
		require("mini.splitjoin").setup()
		require("mini.operators").setup()
		require("mini.bracketed").setup({
			buffer = { suffix = "", options = {} },
			comment = { suffix = "c", options = {} },
			conflict = { suffix = "x", options = {} },
			diagnostic = { suffix = "d", options = {} },
			file = { suffix = "f", options = {} },
			indent = { suffix = "i", options = {} },
			jump = { suffix = "j", options = {} },
			location = { suffix = "l", options = {} },
			oldfile = { suffix = "o", options = {} },
			quickfix = { suffix = "q", options = {} },
			treesitter = { suffix = "t", options = {} },
			undo = { suffix = "u", options = {} },
			window = { suffix = "", options = {} },
			yank = { suffix = "y", options = {} },
		})

		vim.keymap.set("n", "<leader>ld", function()
			MiniDiff.toggle_overlay()
		end, { noremap = true, silent = true, desc = "Git diff toggle" })
	end,
}
