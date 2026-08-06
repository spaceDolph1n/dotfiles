-- Formatting. conform.nvim is the single source of truth; every language
-- server that offers formatting has it disabled in nvim/lsp/<name>.lua.
--
-- `{ "prettierd", "prettier" }` means "run prettierd, THEN prettier" unless
-- `stop_after_first` is set -- the config used to double-format every JS/TS
-- file on save. The prettier list is built once and shared below.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = "ConformInfo",
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
