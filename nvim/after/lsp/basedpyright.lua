-- Python type checking. Ruff owns lint/format/imports and has its hover
-- disabled (nvim/lsp/ruff.lua), so the two do not overlap: basedpyright
-- provides types, hover and go-to-definition, ruff provides diagnostics.
---@type vim.lsp.Config
return {
	settings = {
		basedpyright = {
			-- basedpyright defaults to "recommended", which turns on a large set
			-- of strict rules and is very loud on an existing FastAPI codebase.
			-- "standard" matches what pyright itself defaults to.
			analysis = {
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticSeverityOverrides = {
					-- Owned by ruff; reporting them twice double-renders the sign.
					reportUnusedImport = "none",
					reportUnusedVariable = "none",
					reportUnusedFunction = "none",
				},
			},
		},
	},
}
