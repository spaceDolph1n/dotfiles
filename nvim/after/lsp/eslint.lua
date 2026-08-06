-- ESLint: flat config by default, legacy .eslintrc only where a repo needs it.
--
-- ESLint 9 ignores .eslintrc* unless told otherwise, but forcing that globally
-- (an export in .zshrc, or a fixed `cmd_env`) breaks every flat-config repo.
-- The decision has to be per project root.
--
-- IMPORTANT: the knob is the top-level `settings.useFlatConfig`, which the
-- server forwards to ESLint's own `loadESLint({ useFlatConfig })`.
--
-- Two plausible-looking alternatives do NOT work here, both verified against
-- vscode-langservers-extracted 4.10.0:
--   * ESLINT_USE_FLAT_CONFIG as an env var on the server process -- that
--     governs ESLint's *CLI* loader, not the server, which resolves config
--     itself.
--   * settings.experimental.useFlatConfig -- the pre-8.21 knob, which only
--     selects which module path ESLint is imported from.
-- Either one alone yields a server that attaches happily and reports zero
-- diagnostics, which is a very quiet way to lose all your linting.

local FLAT = {
	"eslint.config.js",
	"eslint.config.mjs",
	"eslint.config.cjs",
	"eslint.config.ts",
	"eslint.config.mts",
	"eslint.config.cts",
}

local LEGACY = {
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.mjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
	".eslintrc",
}

---@param dir string
---@param names string[]
---@return boolean
local function any_exists(dir, names)
	for _, name in ipairs(names) do
		if vim.uv.fs_stat(dir .. "/" .. name) then
			return true
		end
	end
	return false
end

--- A root is "legacy" only when it has an .eslintrc* and no flat config.
---@param root string?
---@return boolean
local function uses_legacy_config(root)
	if not root then
		return false
	end
	if any_exists(root, FLAT) then
		return false
	end
	return any_exists(root, LEGACY)
end

--- nvim-lspconfig's own lsp/eslint.lua uses before_init to set
--- settings.workspaceFolder (which bounds how far the server walks looking for
--- a config) and to wrap the command for Yarn PnP projects. Defining
--- before_init here would silently replace it, so chain to it rather than
--- duplicating logic that upstream may change.
---@param params lsp.InitializeParams
---@param config vim.lsp.ClientConfig
local function call_lspconfig_before_init(params, config)
	for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/eslint.lua", true)) do
		if path:find("nvim%-lspconfig", 1, false) then
			local ok, base = pcall(dofile, path)
			if ok and type(base) == "table" and type(base.before_init) == "function" then
				base.before_init(params, config)
			end
			return
		end
	end
end

---@type vim.lsp.Config
return {
	-- No `cmd` override here on purpose: lspconfig's cmd already prefers a
	-- project-local node_modules/.bin/vscode-eslint-language-server over the
	-- Mason one, and replacing it pinned every repo to the global server.
	before_init = function(params, config)
		call_lspconfig_before_init(params, config)

		if uses_legacy_config(config.root_dir) then
			-- Mutate in place: the client copies `settings` by reference before
			-- before_init runs (see vim/lsp/client.lua), so reassigning the
			-- table here would not reach the client.
			config.settings = config.settings or {}
			config.settings.useFlatConfig = false
		end
	end,
	settings = {
		workingDirectories = { mode = "auto" },
		-- conform.nvim owns formatting; ESLint only reports and fixes lint rules.
		format = false,
	},
}
