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
				{
					pane = 2,
					section = "terminal",
					cmd = "square",
					height = 5,
					padding = 1,
				},
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
		-- git = { enabled = true },
		indent = { enabled = true },
		image = { enabled = true },
		-- input = { enabled = true },
		lazygit = { enabled = true },
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
		-- Git
		{
			"<leader>lb",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>lf",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit Current File History",
		},
		{
			"<leader>lg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>ll",
			function()
				Snacks.lazygit.log()
			end,
			desc = "Lazygit Log (cwd)",
		},
		-- Explorer
		{
			"<leader>e",
			function()
				Snacks.explorer.open()
			end,
			desc = "Open Explorer",
		},
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
		-- LSP
		{
			"<leader>gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Definition",
		},
		{
			"<leader>gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Declaration",
		},
		{
			"<leader>gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"<leader>gi",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Implementation",
		},
		{
			"<leader>gt",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Type Definition",
		},
		{
			"<leader>fl",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
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
	end,
}
