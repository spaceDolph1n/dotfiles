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

		-- Split-open the entry under the cursor, mirroring the pickers' keys.
		-- mini.files has no built-in: swap its target window for a fresh split,
		-- then go in. Directories are just entered -- a split there would be empty.
		local map_split = function(buf_id, lhs, direction, desc)
			vim.keymap.set("n", lhs, function()
				local entry = MiniFiles.get_fs_entry()
				if entry == nil or entry.fs_type ~= "file" then
					return MiniFiles.go_in({})
				end

				local target = MiniFiles.get_explorer_state().target_window
				local new_target = vim.api.nvim_win_call(target, function()
					vim.cmd(direction .. " split")
					return vim.api.nvim_get_current_win()
				end)
				MiniFiles.set_target_window(new_target)

				MiniFiles.go_in({ close_on_file = true })
			end, { buffer = buf_id, desc = desc })
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id
				map_split(buf_id, "<C-s>", "belowright horizontal", "Open in horizontal split")
				map_split(buf_id, "<C-v>", "belowright vertical", "Open in vertical split")
				map_split(buf_id, "<C-t>", "tab", "Open in new tab")
			end,
		})

		require("mini.icons").setup()
		-- Single icon source. Plugins that hard-require nvim-web-devicons get
		-- mini.icons' shim instead, so nvim-web-devicons can be dropped.
		MiniIcons.mock_nvim_web_devicons()

		-- Both defaults are moved off: `gr` shadows Neovim's native LSP maps
		-- (grr/grn/gra/gri), and `gs` became a prefix of mini.surround's gsa/gsd.
		-- `gx` is left alone -- mini relocates the native URL-open to `gX`.
		require("mini.operators").setup({
			replace = { prefix = "cr" },
			sort = { prefix = "gz" },
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
