return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		dashboard = {
			enabled = true,
			sections = {
				{ section = "header" },
				-- {
				-- 	pane = 2,
				-- 	section = "terminal",
				-- 	cmd = "square",
				-- 	height = 5,
				-- 	padding = 1,
				-- },
				{ section = "keys", gap = 2, padding = 1 },
				{ pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
				{
					pane = 2,
					icon = " ",
					title = "Git Status",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status --short --branch --renames -z && git diff --shortstat",
					height = 7,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{
					pane = 2,
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					section = "terminal",
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
					icon = " ",
					title = "Open PRs",
					cmd = "gh pr list -L 3",
					key = "p",
					action = function()
						vim.fn.jobstart("gh pr list --web", { detach = true })
					end,
					height = 7,
				},
				{ section = "startup" },
			},
		},
		-- Disables treesitter, LSP and syntax above a size threshold. Now that
		-- treesitter runs on every filetype, a 4MB bundle or a big lockfile is
		-- otherwise parsed on open (measured: ~1.4s for 4MB of JS, and that was
		-- headless -- no rendering and no LSP attach).
		bigfile = { enabled = true },
		-- git = { enabled = true },
		-- Renders the file before plugins finish loading.
		quickfile = { enabled = true },
		indent = { enabled = true },
		image = { enabled = true, doc = { enabled = false } },
		-- Replaces vim.ui.input; the DAP conditional-breakpoint prompt uses it.
		input = { enabled = true },
		lazygit = { enabled = true },
		-- LSP-aware file renames -- wired to mini.files below.
		rename = { enabled = true },
		gitbrowse = { enabled = true },
		-- Fold column + signs in one place. Replaces nvim-origami's contribution
		-- now that treesitter provides foldexpr.
		statuscolumn = { enabled = true },
		-- NOTE: `scope` is deliberately NOT enabled. Its default keys map [i / ]i,
		-- which mini.bracketed already uses for indent jumps, and its ii / ai
		-- textobjects overlap mini.ai.
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = {
			enabled = true,
			win = {
				-- input window
				input = {
					keys = {
						["<c-h>"] = { "toggle_hidden", mode = { "i", "n" } },
					},
				},
			},
		},
		terminal = { enabled = true, win = {
			wo = {
				winbar = "",
			},
		} },
		toggle = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		-- UI
		{
			"<leader>un",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>uN",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		-- Git (moved from <leader>l to match the near-universal convention)
		{
			"<leader>gb",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>gf",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit Current File History",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit.log()
			end,
			desc = "Lazygit Log (cwd)",
		},
		{
			-- Opens the current line (or visual range) on GitHub at the exact
			-- commit -- the link is stable, unlike a branch URL.
			"<leader>go",
			function()
				Snacks.gitbrowse()
			end,
			mode = { "n", "x" },
			desc = "Open in GitHub",
		},
		-- NOTE: no <leader>e here. mini.files also binds <leader>e and loads
		-- later, so snacks.explorer was permanently unreachable.
		-- Picker
		{
			"<leader><space>",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Files",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Recent",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		{
			"<leader>fa",
			function()
				Snacks.picker()
			end,
			desc = "All",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.todo_comments()
			end,
			desc = "Todos",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>fq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		-- LSP (moved from <leader>g, which is now Git).
		-- Neovim 0.11+ also has native gd/grr/gri/grt/grn/gra -- these give the
		-- same navigation through the snacks picker UI.
		{
			"<leader>ld",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Definition",
		},
		{
			"<leader>lD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Declaration",
		},
		{
			"<leader>lr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"<leader>li",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Implementation",
		},
		{
			"<leader>lt",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Type Definition",
		},
		{
			"<leader>ls",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Document Symbols",
		},
		-- Other
		{
			"<leader>/",
			function()
				Snacks.terminal.toggle()
			end,
			desc = "Toggle Terminal",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
			mode = { "n", "t" },
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
			mode = { "n", "t" },
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.zoom():map("<leader>uz")
				Snacks.toggle.indent():map("<leader>ug")
				Snacks.toggle.dim():map("<leader>uD")
			end,
		})

		-- Make mini.files renames LSP-aware: renaming a component through the
		-- explorer now asks every attached server to update imports, instead of
		-- leaving a trail of broken paths to fix by hand.
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesActionRename",
			group = vim.api.nvim_create_augroup("snacks_lsp_rename", { clear = true }),
			callback = function(ev)
				Snacks.rename.on_rename_file(ev.data.from, ev.data.to)
			end,
		})
	end,
}
