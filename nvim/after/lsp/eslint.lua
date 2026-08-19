-- Flat config per project root, because ESLint 9 ignores .eslintrc* and forcing
-- it globally breaks flat-config repos. Only top-level `settings.useFlatConfig`
-- works -- env vars and `experimental.useFlatConfig` attach and then report zero
-- diagnostics. In after/lsp/: last runtimepath entry wins, so nvim/lsp/ loses.

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

--- lspconfig's before_init sets settings.workspaceFolder and wraps the command
--- for Yarn PnP. Ours replaces it outright, so chain rather than duplicate.
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
