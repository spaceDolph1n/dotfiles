-- ESLint: flat config by default, legacy .eslintrc only where a repo needs it.
--
-- ESLint 9 ignores .eslintrc* unless told otherwise, but forcing that globally
-- (an export in .zshrc, or a fixed `cmd_env`) breaks every flat-config repo, so
-- the decision has to be made per project root.
--
-- Three things that look like they should work, and do not (all verified
-- against vscode-langservers-extracted 4.10.0):
--   * ESLINT_USE_FLAT_CONFIG as an env var on the server process -- that drives
--     ESLint's *CLI* loader; the language server resolves config itself.
--   * settings.experimental.useFlatConfig -- the pre-8.21 knob, which only
--     picks which module path ESLint is imported from. (nvim-lspconfig's own
--     docstring still recommends this one; it is out of date.)
--   * putting this file in nvim/lsp/ -- when several runtimepath entries supply
--     lsp/eslint.lua the LAST wins, and plugin dirs come after user config, so
--     nvim-lspconfig's before_init silently replaced ours. Hence after/lsp/.
-- Each failure mode yields a server that attaches happily and reports zero
-- diagnostics, which is a very quiet way to lose all your linting.
--
-- The setting that works is the top-level `settings.useFlatConfig`, which the
-- server forwards to ESLint's own loadESLint().

--- True when `root` has an .eslintrc* and no flat config. One directory scan,
--- rather than probing ~13 candidate filenames.
---@param root string?
---@return boolean
local function uses_legacy_config(root)
	if not root then
		return false
	end
	local legacy = false
	for name in vim.fs.dir(root) do
		if name:match("^eslint%.config%.") then
			return false -- a flat config wins outright
		end
		legacy = legacy or name:match("^%.eslintrc") ~= nil
	end
	return legacy
end

--- nvim-lspconfig's lsp/eslint.lua uses before_init to set
--- settings.workspaceFolder (which bounds how far the server walks looking for
--- a config) and to wrap the command for Yarn PnP projects. Ours replaces it
--- outright, so chain to it rather than duplicating logic upstream may change.
local function call_lspconfig_before_init(params, config)
	for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/eslint.lua", true)) do
		if path:find("nvim%-lspconfig") then
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
	-- No `cmd` override on purpose: lspconfig's already prefers a project-local
	-- node_modules/.bin/vscode-eslint-language-server over the Mason one.
	before_init = function(params, config)
		call_lspconfig_before_init(params, config)

		if uses_legacy_config(config.root_dir) then
			-- Mutate in place: the client captures `settings` by reference before
			-- before_init runs, so reassigning the table would not reach it.
			config.settings.useFlatConfig = false
		end
	end,
	settings = {
		workingDirectories = { mode = "auto" },
		-- conform.nvim owns formatting; ESLint only reports and fixes lint rules.
		format = false,
	},
}
