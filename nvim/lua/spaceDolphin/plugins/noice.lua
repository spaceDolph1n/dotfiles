return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		-- You can enable a preset for easier configuration
		presets = {
			bottom_search = false, -- Use a classic bottom cmdline for search
			command_palette = true, -- Position the cmdline and popupmenu together
			long_message_to_split = true, -- Long messages will be sent to a split
			inc_rename = false, -- Enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- Add a border to hover docs and signature help
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
}
