return {
	enabled = true,
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"jay-babu/mason-nvim-dap.nvim", -- Add this line
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")
		local mason_dap = require("mason-nvim-dap") -- Add this line

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"bashls",
				"eslint",
				"intelephense",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"volar",
				"phpactor",
			},
			automatic_installation = true, -- Automatically install LSP servers
		})

		-- Add this block for DAP configuration
		mason_dap.setup({
			ensure_installed = {
				"js-debug-adapter", -- For JavaScript/TypeScript
				"php-debug-adapter", -- For PHP
				"node-debug2-adapter", -- Alternative JS debugger
			},
			automatic_installation = true, -- Automatically install debug adapters
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"blade-formatter",
				"phpcs", -- for linting php
				"eslint_d",
				"pint", -- Pint for Laravel PHP formatting
			},
		})
	end,
}
