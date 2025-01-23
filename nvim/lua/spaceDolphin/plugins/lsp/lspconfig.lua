return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Go to references"
				keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Go to definitions"
				keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Go to implementations"
				keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Go to type definitions"
				keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>tr", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>ts", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Disable virtual text but keep the diagnostic signs in the gutter
		vim.diagnostic.config({
			virtual_text = false, -- Turn off virtual text (text next to the line)
			signs = true, -- Keep signs (icons in the gutter)
			underline = true, -- Optionally keep underlines for diagnostics
			update_in_insert = true, -- Optionally update diagnostics in insert mode
			severity_sort = true, -- Optionally sort diagnostics by severity
		})

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			-- default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			["svelte"] = function()
				-- configure svelte server
				lspconfig["svelte"].setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								-- Here use ctx.match instead of ctx.file
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,
			["graphql"] = function()
				-- configure graphql language server
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["emmet_ls"] = function()
				-- configure emmet language server
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
				})
			end,
			["lua_ls"] = function()
				-- configure lua server (with special settings)
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							-- make the language server recognize "vim" global
							diagnostics = {
								globals = { "vim" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				})
			end,
			["volar"] = function()
				lspconfig["volar"].setup({
					filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" },
				})
			end,
			["tailwindcss"] = function()
				lspconfig["tailwindcss"].setup({
					cmd = { "tailwindcss-language-server", "--stdio" },
					root_dir = lspconfig.util.root_pattern("tailwind.config.js", "package.json"),
				})
			end,
			["intelephense"] = function()
				lspconfig["intelephense"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						intelephense = {
							stubs = {
								"wordpress",
								"acf-pro",
								"wordpress-globals",
								"wp-cli",
							},
							environment = {
								includePaths = {
									"/Users/tiagorodrigues/.composer/vendor/php-stubs/",
								},
							},
							files = {
								maxSize = 5000000,
							},
							-- Disable diagnostics and formatting
							diagnostics = {
								enable = false, -- Disable diagnostic checking
							},
							formatting = {
								enable = false, -- Disable auto formatting
							},
							completion = {
								enable = true, -- Enable autocompletion
							},
						},
					},
					filetypes = { "php", "blade" },
				})
			end,
			["phpactor"] = function()
				lspconfig["phpactor"].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = {
						phpactor = {
							stubs = {
								"wordpress",
								"acf-pro",
								"wordpress-globals",
								"wp-cli",
							},
						},
					},
					filetypes = { "php", "blade" },
				})
			end,
		})
	end,
}
