return {
	"windwp/nvim-ts-autotag",
	lazy = false,
	config = function()
		require("nvim-ts-autotag").setup({
			filetypes = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "blade" },
		})
	end,
}
