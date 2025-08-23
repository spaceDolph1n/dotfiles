return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			-- do I still need this for mini.ai?
			textobjects = {
				select = {
					enable = false,
				},
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		})
		-- -- Additional configuration to add Blade filetype detection
		-- vim.filetype.add({
		-- 	pattern = {
		-- 		[".*%.blade%.php"] = "blade", -- Recognize Blade files
		-- 	},
		-- })
		--
		-- -- Configure the custom Tree-sitter Blade parser
		-- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		-- parser_config.blade = {
		-- 	install_info = {
		-- 		url = "https://github.com/EmranMR/tree-sitter-blade", -- URL for Blade parser repo
		-- 		files = { "src/parser.c" }, -- Location of the parser source file
		-- 		branch = "main", -- Use the main branch
		-- 	},
		-- 	filetype = "blade", -- Map this parser to the "blade" filetype
		-- }
	end,
}
