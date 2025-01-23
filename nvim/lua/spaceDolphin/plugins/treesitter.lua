return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = true,
			},
			-- enable indentation
			indent = { enable = true },
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"blade", -- Add Blade to ensure it's installed
				"php_only", -- PHP-only parser needed for Blade
				"php",
				"phpdoc",
				"go",
				"toml",
				"vue",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = false,
				},
			},
		})

		-- Additional configuration to add Blade filetype detection
		vim.filetype.add({
			pattern = {
				[".*%.blade%.php"] = "blade", -- Recognize Blade files
			},
		})

		-- Configure the custom Tree-sitter Blade parser
		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		parser_config.blade = {
			install_info = {
				url = "https://github.com/EmranMR/tree-sitter-blade", -- URL for Blade parser repo
				files = { "src/parser.c" }, -- Location of the parser source file
				branch = "main", -- Use the main branch
			},
			filetype = "blade", -- Map this parser to the "blade" filetype
		}
	end,
}
