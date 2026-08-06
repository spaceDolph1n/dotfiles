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
			-- Suffixes left empty are handled by Neovim 0.11+ natively:
			--   buffer -> [b/]b, quickfix -> [q/]q, location -> [l/]l,
			--   diagnostic -> [d/]d, file -> [f/]f
			buffer = { suffix = "", options = {} },
			comment = { suffix = "c", options = {} },
			conflict = { suffix = "x", options = {} },
			diagnostic = { suffix = "", options = {} },
			file = { suffix = "", options = {} },
			indent = { suffix = "i", options = {} },
			jump = { suffix = "j", options = {} },
			location = { suffix = "", options = {} },
			oldfile = { suffix = "o", options = {} },
			quickfix = { suffix = "", options = {} },
			treesitter = { suffix = "", options = {} },
			undo = { suffix = "u", options = {} },
			window = { suffix = "", options = {} },
			yank = { suffix = "y", options = {} },
		})
		require("mini.diff").setup()
		require("mini.files").setup()

		require("mini.icons").setup()
		-- Single icon source. Plugins that hard-require nvim-web-devicons get
		-- mini.icons' shim instead, so nvim-web-devicons can be dropped.
		MiniIcons.mock_nvim_web_devicons()

		-- Two of mini.operators' default prefixes collide with things that
		-- matter more here:
		--
		--   `gr` (replace) shadows Neovim 0.11's native LSP maps -- `grr`
		--        (references) was overridden outright by "replace line", and
		--        grn/gra/gri/grt each had to wait out timeoutlen first.
		--        `cr` is upstream's own suggested alternative.
		--   `gs` (sort) became a prefix of mini.surround's gsa/gsd/gsr after
		--        surround moved off `s`, so every sort waited on the ambiguity.
		--
		-- `gx` is left alone: mini relocates the native URL-open to `gX`.
		require("mini.operators").setup({
			replace = { prefix = "cr" },
			sort = { prefix = "gz" },
		})
		require("mini.pairs").setup()
		require("mini.splitjoin").setup()

		-- Moved off the default `s` prefix onto `gs`.
		--
		-- mini.surround's defaults (sa/sd/sr/sf/sF/sh/sn) made plain `s` a
		-- prefix of 16 longer mappings, so flash.nvim's `s` jump could not fire
		-- until `timeoutlen` (500ms) elapsed -- on every single jump. Surround
		-- is the lower-frequency action, so it is the one that moved.
		require("mini.surround").setup({
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		})

		vim.keymap.set("n", "<leader>gd", function()
			MiniDiff.toggle_overlay()
		end, { noremap = true, silent = true, desc = "Git diff overlay" })

		vim.keymap.set("n", "<leader>e", function()
			if package.loaded["mini.files"] and require("mini.files").close() then
				return
			end
			require("mini.files").open(vim.api.nvim_buf_get_name(0))
		end, { noremap = true, silent = true, desc = "Toggle file explorer" })
	end,
}
