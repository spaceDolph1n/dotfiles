-- Formatting. conform.nvim is the single source of truth; every language
-- server that offers formatting has it disabled in nvim/after/lsp/<name>.lua.
--
-- `{ "prettierd", "prettier" }` means "run prettierd, THEN prettier" unless
-- `stop_after_first` is set -- the config used to double-format every JS/TS
-- file on save. The prettier list is built once and shared below.
--
-- conform resolves a project-local node_modules/.bin/prettier before the Mason
-- one, and prettierd honours the repo's pinned prettier major, so a repo on
-- prettier 2 keeps prettier 2's defaults.
local prettier = { "prettierd", "prettier", stop_after_first = true }

--- Executable prettier configs get require()d into the prettierd daemon and
--- cached in its Node module registry, which is never invalidated -- edit
--- .prettierrc.js and you keep getting the previous formatting until the daemon
--- restarts. Static configs (.prettierrc.json, package.json#prettier) are
--- re-read correctly, so this only needs to cover the executable ones.
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
