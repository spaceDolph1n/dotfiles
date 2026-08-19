-- conform.nvim is the single source of truth; LSP formatting is disabled in
-- nvim/after/lsp/<name>.lua. `stop_after_first` matters -- without it the list
-- means "prettierd THEN prettier", which double-formats every save.
local prettier = { "prettierd", "prettier", stop_after_first = true }

--- prettierd caches executable configs in its Node registry and never
--- invalidates them, so edits keep formatting with the old rules until it
--- restarts. Static configs (.prettierrc.json, package.json) re-read fine.
local PRETTIER_EXECUTABLE_CONFIGS = {
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.ts",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
}

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = "ConformInfo",
	init = function()
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("prettierd_reload", { clear = true }),
			pattern = PRETTIER_EXECUTABLE_CONFIGS,
			callback = function()
				if vim.fn.executable("prettierd") == 0 then
					return
				end
				vim.system({ "prettierd", "restart" }, { text = true }, function()
					vim.schedule(function()
						vim.notify("prettierd restarted (config changed)", vim.log.levels.INFO)
					end)
				end)
			end,
		})
	end,
	keys = {
		{
			"<leader>uf",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify(
					"Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"),
					vim.log.levels.INFO
				)
			end,
			desc = "Toggle Format on Save",
		},
	},
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			-- ruff replaces black + isort with one binary, and is the same
			-- binary already backing the `ruff` language server.
			python = { "ruff_organize_imports", "ruff_format" },
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			vue = prettier,
			css = prettier,
			scss = prettier,
			html = prettier,
			json = prettier,
			jsonc = prettier,
			yaml = prettier,
			markdown = prettier,
			graphql = prettier,
		},
		default_format_opts = {
			-- Was `lsp_fallback = true`, deprecated in favour of this.
			lsp_format = "fallback",
		},
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
	},
}
