-- Language servers.
--
-- Per-server settings live in `nvim/lsp/<name>.lua` (Neovim 0.12 reads these
-- off the runtimepath automatically -- see :h lsp-config). This file only
-- decides *which* servers exist and makes sure their binaries are installed.
--
-- Diagnostics are configured in core/options.lua, since `vim.diagnostic` is
-- core and should not depend on this spec having loaded.

--- Language servers to install and enable.
local SERVERS = {
	"basedpyright", -- Python types; ruff handles lint/format
	"emmet_ls",
	"eslint",
	"html",
	"lua_ls",
	"marksman",
	"ruff",
	"tailwindcss",
	"vtsls",
	"vue_ls",
}

--- CLI tools used by conform.nvim and nvim-dap. Not language servers -- these
--- must never be passed to mason-lspconfig or they get started as LSP servers.
local TOOLS = {
	"debugpy", -- nvim-dap: Python / FastAPI
	"js-debug-adapter", -- nvim-dap: Node, Next.js, Vue
	"prettier",
	"prettierd",
	"stylua",
}

return {
	{
		-- The `williamboman/*` repos were transferred to the `mason-org` org;
		-- the old paths are redirects that will eventually rot.
		"mason-org/mason.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mason-org/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = SERVERS,
				-- `automatic_enable = true` calls vim.lsp.enable() for *every*
				-- installed mason package that ships an lsp/ config -- not just
				-- the ones listed above. That is how `stylua` ended up running
				-- as `stylua --lsp` on every Lua buffer, as a second formatting
				-- provider racing conform. Enable explicitly instead.
				automatic_enable = false,
			})

			-- Advertise blink.cmp's completion capabilities to every server.
			-- blink does not register these itself, so this is still required.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			vim.lsp.enable(SERVERS)

			-- Install formatter binaries declaratively. Replaces
			-- mason-conform.nvim, whose auto-installs are what put `stylua`
			-- into Mason and triggered the phantom-LSP problem above.
			local registry = require("mason-registry")
			registry.refresh(function()
				for _, name in ipairs(TOOLS) do
					local ok, pkg = pcall(registry.get_package, name)
					if ok and not pkg:is_installed() then
						pkg:install()
					end
				end
			end)
		end,
	},
}
