-- Which language servers exist and get installed. Per-server settings live in
-- `nvim/lsp/<name>.lua`, read off the runtimepath (:h lsp-config); diagnostics
-- are in core/options.lua so they do not depend on this spec loading.

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
				-- `true` enables *every* installed mason package shipping an lsp/
				-- config, not just SERVERS -- that is how stylua ended up running
				-- as `stylua --lsp`, racing conform. Enable explicitly instead.
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
