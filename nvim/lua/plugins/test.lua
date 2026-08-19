return {
	{
		"nvim-neotest/neotest",
		-- FixCursorHold dropped: a workaround for a CursorHold bug fixed in
		-- Neovim years ago. neotest-plenary (Lua plugin tests) and neotest-bash
		-- dropped: no such tests in this stack.
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- Adapters
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-jest",
			"nvim-neotest/neotest-python",
			"thenbe/neotest-playwright",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vitest"),
					require("neotest-python")({
						dap = { adapter = "debugpy" },
					}),
					require("neotest-playwright").adapter({
						options = {
							persist_project_selection = true,
							enable_dynamic_test_discovery = true,
						},
					}),
					require("neotest-jest")({
						jestCommand = "npm test --",
						jestArguments = function(defaultArguments, context)
							return defaultArguments
						end,
						env = { CI = true },
						cwd = function(path)
							return vim.fn.getcwd()
						end,
						isTestFile = require("neotest-jest.jest-util").defaultIsTestFile,
					}),
				},
			})
		end,
		keys = {
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
				end,
				desc = "Run Nearest",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.api.nvim_buf_get_name(0))
				end,
				desc = "Run File",
			},
			{
				-- Routes through nvim-dap. Python is wired via neotest-python's
				-- `dap` option above; the JS adapters still need theirs.
				"<leader>td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Debug Nearest",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Toggle Summary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "Show Output",
			},
			{
				"<leader>tp",
				function()
					-- This triggers the project selector you mentioned
					vim.cmd("NeotestPlaywrightProject")
				end,
				desc = "Select Playwright Project",
			},
		},
	},
}
