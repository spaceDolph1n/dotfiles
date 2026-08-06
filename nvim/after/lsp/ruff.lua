-- Replaces pylint (nvim-lint) + black + isort (conform) with one Rust binary.
---@type vim.lsp.Config
return {
	init_options = {
		settings = {
			lineLength = 88,
			organizeImports = true,
			lint = { enable = true },
			format = { preview = false },
		},
	},
	on_attach = function(client)
		-- Ruff has no type information; leave hover to a real type server if
		-- one is ever added (basedpyright).
		client.server_capabilities.hoverProvider = false
	end,
}
