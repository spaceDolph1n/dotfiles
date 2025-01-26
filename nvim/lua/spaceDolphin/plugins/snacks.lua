return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		animate = { enabled = true },
		bigfile = { enabled = true },
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
		dim = { enabled = true },
		git = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 5000,
		},
		picker = { enabled = true },
		quickfile = { enabled = true },
		rename = { enabled = true },
		scroll = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },
		words = { enabled = true }, -- what is this doing?
		zen = { enabled = true },
	},
	keys = {
		{
			"<leader>un",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>cR",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
		{
			"<leader>fp",
			function()
				Snacks.picker()
			end,
			desc = "Snacks Picker",
		},
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
		{
			"<leader>uN",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
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
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.zen():map("<leader>uz")
				Snacks.toggle.zoom():map("<leader>uZ")
				Snacks.toggle.inlay_hints():map("<leader>uH")
				Snacks.toggle.indent():map("<leader>ug")
				Snacks.toggle.dim():map("<leader>uD")
			end,
		})
	end,
}
