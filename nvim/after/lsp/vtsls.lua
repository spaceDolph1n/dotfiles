local inlay = {
	enumMemberValues = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
	parameterNames = { enabled = "literals" },
	parameterTypes = { enabled = true },
	propertyDeclarationTypes = { enabled = true },
	variableTypes = { enabled = false },
}

---@type vim.lsp.Config
return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"mdx",
	},
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true,
			experimental = {
				-- Expand the "..." in long type errors instead of truncating.
				maxInlayHintLength = 30,
				completion = { enableServerSideFuzzyMatch = true },
			},
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
						configNamespace = "typescript",
					},
				},
			},
		},
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = inlay,
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = inlay,
		},
	},
}
