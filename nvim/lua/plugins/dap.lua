-- Debugging: nvim-dap wired for TypeScript/JavaScript (Node, Next.js, Vue) and
-- Python (FastAPI).
--
-- Adapters come from Mason:
--   js-debug-adapter -> vscode-js-debug, the same engine VS Code uses
--   debugpy          -> Python; also what neotest-python is already configured
--                       against in plugins/test.lua
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			"theHamsta/nvim-dap-virtual-text",
			"mfussenegger/nvim-dap-python",
		},
		keys = {
			-- Core loop. F-keys mirror VS Code so the two don't fight each other.
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue / Start",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dB",
				function()
					vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
						if cond and cond ~= "" then
							require("dap").set_breakpoint(cond)
						end
					end)
				end,
				desc = "Conditional Breakpoint",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dr",
				function()
					require("dap").restart()
				end,
				desc = "Restart",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval(nil, { enter = true })
				end,
				mode = { "n", "v" },
				desc = "Evaluate Expression",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>dR",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup({
				-- Inline values only where the debugger actually reports them.
				virt_text_pos = "eol",
				commented = true,
			})

			-- Open/close the UI with the session automatically.
			dap.listeners.after.event_initialized["dapui"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui"] = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

			------------------------------------------------------------------
			-- JavaScript / TypeScript (vscode-js-debug)
			------------------------------------------------------------------
			local mason = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

			for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
				dap.adapters[adapter] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = { mason .. "/js-debug/src/dapDebugServer.js", "${port}" },
					},
				}
			end

			local js_filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue" }

			for _, ft in ipairs(js_filetypes) do
				dap.configurations[ft] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch current file (tsx)",
						runtimeExecutable = "npx",
						runtimeArgs = { "tsx" },
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						protocol = "inspector",
						console = "integratedTerminal",
						skipFiles = { "<node_internals>/**", "**/node_modules/**" },
					},
					{
						-- For `next dev`, `nest start --debug`, `node --inspect`, etc.
						-- Start the process yourself, then attach.
						type = "pwa-node",
						request = "attach",
						name = "Attach to running Node process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**", "**/node_modules/**" },
					},
					{
						-- Next.js / Vue client side. Run the dev server first.
						type = "pwa-chrome",
						request = "launch",
						name = "Launch Chrome against localhost:3000",
						url = "http://localhost:3000",
						webRoot = "${workspaceFolder}",
						sourceMaps = true,
						userDataDir = false,
					},
				}
			end

			------------------------------------------------------------------
			-- Python (debugpy)
			------------------------------------------------------------------
			local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
			if vim.fn.executable(debugpy) == 1 then
				require("dap-python").setup(debugpy)
			end

			-- Assign before inserting: `table.insert(x or {}, …)` writes into a
			-- throwaway table when x is nil, so the config vanishes silently if
			-- the debugpy guard above didn't run.
			dap.configurations.python = dap.configurations.python or {}
			table.insert(dap.configurations.python, {
				type = "python",
				request = "launch",
				name = "FastAPI (uvicorn)",
				module = "uvicorn",
				args = function()
					local app = vim.fn.input("ASGI app (module:attr): ", "app.main:app")
					return { app, "--reload", "--port", "8000" }
				end,
				cwd = "${workspaceFolder}",
				justMyCode = false,
			})
		end,
	},
}
