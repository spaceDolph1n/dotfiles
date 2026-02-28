return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
						},
					},
				},
				html = {},
				emmet_ls = {},
				tailwindcss = {},
				vue_ls = {},
				vtsls = {
					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "mdx" },
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vim.fn.stdpath("data")
											.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
										languages = { "vue" },
									},
								},
							},
						},
					},
					on_attach = function(client)
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end,
				},
				phpactor = {},
				eslint = {},
				marksman = {},
			},
		},
		config = function()
			-- Only global setup, no per-server setup!
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"html",
					"emmet_ls",
					"tailwindcss",
					"vue_ls",
					"vtsls",
					"phpactor",
					"eslint",
					"marksman",
				},
				automatic_installation = true,
			})
			-- Global diagnostics settings
			vim.diagnostic.config({
				virtual_text = false,
				virtual_lines = { current_line = true },
				severity_sort = true,
			})
		end,
	},
}
