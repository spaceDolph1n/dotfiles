---@type vim.lsp.Config
return {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim", "Snacks", "MiniDiff" } },
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("lua", true),
			},
			hint = { enable = true, arrayIndex = "Disable" },
			telemetry = { enable = false },
			-- stylua owns formatting (see plugins/format.lua).
			format = { enable = false },
		},
	},
}
