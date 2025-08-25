return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		-- Override eslint_d to remove deprecated flags
		lint.linters.eslint_d = {
			cmd = "eslint_d",
			stdin = true,
			args = {
				"--format",
				"json",
				"--stdin",
				"--stdin-filename",
				function()
					return vim.api.nvim_buf_get_name(0)
				end,
			},
			stream = "stdout",
			ignore_exitcode = true,
			parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
				source = "eslint_d",
				severity = vim.diagnostic.severity.ERROR,
			}),
		}
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			vue = { "eslint_d" },
			php = { "phpcs" },
			blade = { "phpcs" },
			python = { "pylint" },
		}

		-- Lint automatically on file events
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
