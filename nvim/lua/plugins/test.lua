--- Both JS adapters claim `*.spec.ts` on the filename alone and neotest takes
--- whichever answers first, so Playwright was swallowing every Jest spec. The
--- import splits them, and travels to repos that keep e2e tests elsewhere.
local function usesPlaywright(path)
	local file = io.open(path, "r")
	if not file then
		return false
	end
	local head = file:read(4096) or ""
	file:close()
	return head:find("@playwright/test", 1, true) ~= nil
end

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
							is_test_file = function(path)
								return (path:match("%.spec%.[tj]sx?$") or path:match("%.test%.[tj]sx?$")) ~= nil
									and usesPlaywright(path)
							end,
						},
					}),
					require("neotest-jest")({
						jestCommand = "npx jest",
						env = { CI = true },
						--- Run from the file's own package root, so opening nvim
						--- deeper than the repo root still finds the jest config.
						cwd = function(path)
							return vim.fs.root(path, "package.json")
						end,
						isTestFile = function(path)
							return require("neotest-jest.jest-util").defaultIsTestFile(path)
								and not usesPlaywright(path)
						end,
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
