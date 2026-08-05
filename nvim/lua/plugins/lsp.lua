return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
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
		config = function(_, opts)
			require("mason").setup()

			local lspconfig = require("lspconfig")
			local blink = require("blink.cmp")

			require("mason-lspconfig").setup({
				-- Automatically installs all keys defined in opts.servers
				ensure_installed = vim.tbl_keys(opts.servers),
				automatic_installation = true,
				handlers = {
					function(server_name)
						local server_opts = opts.servers[server_name] or {}
						-- Injects blink.cmp completion capabilities into each LSP
						server_opts.capabilities = blink.get_lsp_capabilities(server_opts.capabilities)
						lspconfig[server_name].setup(server_opts)
					end,
				},
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
