return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- Adapters
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-jest",
			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-plenary",
			"olimorris/neotest-phpunit",
			"rcasia/neotest-bash",
			"thenbe/neotest-playwright",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vitest"),
					require("neotest-python")({
						dap = { adapter = "debugpy" },
					}),
					require("neotest-jest")({
						jestCommand = "npm test --",
						env = { CI = true },
						cwd = function(path)
							return vim.fn.getcwd()
						end,
					}),
					require("neotest-phpunit"),
					require("neotest-bash"),
					require("neotest-playwright").adapter({
						options = {
							persist_project_selection = true,
							enable_dynamic_test_discovery = true,
						},
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
		},
	},
}
