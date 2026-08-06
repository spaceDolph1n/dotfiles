-- ESLint: flat config by default, legacy .eslintrc only where a repo needs it.
--
-- ESLint 9 ignores .eslintrc* unless ESLINT_USE_FLAT_CONFIG=false, but forcing
-- that globally (as an export in .zshrc) breaks every flat-config repo -- and
-- forcing it in `cmd_env` breaks them inside Neovim specifically. Instead we
-- decide per project root, at spawn time, using `cmd` as a function
-- (:h vim.lsp.ClientConfig). One server per root, each with the right env.

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

---@type vim.lsp.Config
return {
	cmd = function(dispatchers, config)
		local legacy = uses_legacy_config(config.root_dir)
		return vim.lsp.rpc.start({ "vscode-eslint-language-server", "--stdio" }, dispatchers, {
			cwd = config.cmd_cwd,
			detached = config.detached,
			-- Merged into the inherited environment, not a replacement.
			env = legacy and { ESLINT_USE_FLAT_CONFIG = "false" } or nil,
		})
	end,
	settings = {
		-- Leave `useFlatConfig` unset: the server auto-detects, and the env var
		-- above is what actually decides for ESLint's own config loader.
		workingDirectories = { mode = "auto" },
		-- conform.nvim owns formatting; ESLint only reports and fixes lint rules.
		format = false,
	},
}
