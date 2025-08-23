return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		-- only used for color highlighting
		require("mini.hipatterns").setup({
			highlighters = {
				-- Highlight hex color strings (`#rrggbb`) using that color
				hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
			},
		})

		require("mini.ai").setup()
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
			treesitter = { suffix = "", options = {} },
			undo = { suffix = "u", options = {} },
			window = { suffix = "", options = {} },
			yank = { suffix = "y", options = {} },
		})
		require("mini.diff").setup()
		require("mini.files").setup()
		require("mini.icons").setup()
		require("mini.operators").setup()
		require("mini.pairs").setup()
		require("mini.splitjoin").setup()
		require("mini.surround").setup()

		vim.keymap.set("n", "<leader>ld", function()
			MiniDiff.toggle_overlay()
		end, { noremap = true, silent = true, desc = "Git diff toggle" })

		vim.keymap.set("n", "<leader>e", function()
			if package.loaded["mini.files"] and require("mini.files").close() then
				return
			end
			require("mini.files").open(vim.api.nvim_buf_get_name(0))
		end, { noremap = true, silent = true, desc = "Toggle file explorer" })
	end,
}
