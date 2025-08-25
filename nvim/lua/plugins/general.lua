return {
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use
	"christoomey/vim-tmux-navigator", -- tmux & split window navigation
	{
		"windwp/nvim-ts-autotag",
		lazy = false,
		config = function()
			require("nvim-ts-autotag").setup({
				filetypes = {
					"astro",
					"blade",
					"html",
					"javascript",
					"jsx",
					"markdown",
					"php",
					"tsx",
					"typescript",
					"vue",
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			local prehook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
			require("Comment").setup({
				pre_hook = prehook,
			})
		end,
		event = "InsertEnter",
		lazy = true,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			modes = {
				char = {
					jump_labels = true,
				},
			},
		},
  -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
	},
	{
		-- FIX: not worth, delete?
		"danymat/neogen",
		version = "*",
		config = function()
			require("neogen").setup({
				-- ignore_injections = false,
				languages = {
					typescript = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
					typescriptreact = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
					vue = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
				},
			})
		end,
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undo Tree" },
		},
		init = function()
			-- Persist undo, refer https://github.com/mbbill/undotree#usage
			local undodir = vim.fn.expand("~/.undo-nvim")

			if vim.fn.has("persistent_undo") == 1 then
				if vim.fn.isdirectory(undodir) == 0 then
					os.execute("mkdir -p " .. undodir)
				end

				vim.opt.undodir = undodir
				vim.opt.undofile = true
			end
			vim.g.undotree_WindowLayout = 2
		end,
	},
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		keys = {
			{
				"<leader>ts",
				function()
					require("spectre").toggle()
				end,
				desc = "Spectre",
			},
			{
				"<leader>tS",
				function()
					require("spectre").toggle()
				end,
				desc = "Toggle Spectre",
			},
			{
				"<leader>tsw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word",
			},
			{
				"<leader>tsc",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				desc = "Search on current file",
			},
		},
		cmd = {
			"Spectre",
		},
		opts = {},
	},
	{
		"andrewferrier/debugprint.nvim",
		opts = {
			keymaps = {
				normal = {
					plain_below = "g/p",
					plain_above = "g/P",
					variable_below = "g/v",
					variable_above = "g/V",
					surround_plain = "g/sp",
					surround_variable = "g/sv",
					delete_debug_prints = "g/d",
				},
				visual = {
					variable_below = "g/v",
					variable_above = "g/V",
				},
			},
		},

		dependencies = {
			"echasnovski/mini.nvim", -- Optional: Needed for line highlighting (full mini.nvim plugin)
			-- ... or ...
			"echasnovski/mini.hipatterns", -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)
			"folke/snacks.nvim", -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
		},

		lazy = false, -- Required to make line highlighting work before debugprint is first used
		version = "*", -- Remove if you DON'T want to use the stable version
	},
}
