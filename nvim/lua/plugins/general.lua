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
					"html",
					"javascript",
					"jsx",
					"markdown",
					"tsx",
					"typescript",
					"vue",
				},
			})
		end,
	},
	{
		-- Neovim 0.10+ ships the `gc`/`gcc`/`gbc` operators; the only gap is a
		-- correct `commentstring` inside JSX/Vue regions, which is all this does.
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
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
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>xu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undo Tree" },
		},
		init = function()
			-- `undofile`/`undodir` now live in core/options.lua: persistent undo
			-- is a core editor setting, not something that should require a
			-- plugin's `init` to have run.
			vim.g.undotree_WindowLayout = 2
		end,
	},
	{
		-- Project-wide search & replace in a normal editable buffer, driving
		-- ripgrep's `--replace`; switches to ast-grep for syntax-aware rewrites.
		-- For *text* only -- rename a code symbol with `grn` (native LSP rename).
		"MagicDuck/grug-far.nvim",
		cmd = { "GrugFar", "GrugFarWithin" },
		keys = {
			{
				"<leader>xs",
				function()
					require("grug-far").open()
				end,
				desc = "Search & Replace (project)",
			},
			{
				"<leader>xw",
				function()
					require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
				end,
				mode = "n",
				desc = "Replace current word",
			},
			{
				"<leader>xw",
				function()
					require("grug-far").with_visual_selection()
				end,
				mode = "x",
				desc = "Replace selection",
			},
			{
				"<leader>xc",
				function()
					require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
				end,
				desc = "Replace in current file",
			},
			{
				"<leader>xa",
				function()
					require("grug-far").open({ engine = "astgrep" })
				end,
				desc = "Structural Replace (ast-grep)",
			},
		},
		---@module "grug-far"
		---@type GrugFarOptionsOverride
		opts = {
			-- Keep the results buffer out of the way of the file you came from.
			windowCreationCommand = "botright vsplit",
			transient = true,
		},
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
	{
		-- harpoon2 -- pinned files, scoped per project. The picker is *search*;
		-- harpoon is *muscle memory* -- <leader>2 is the same file all day.
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = function()
			local keys = {
				{
					"<leader>ha",
					function()
						require("harpoon"):list():add()
					end,
					desc = "Pin file",
				},
				{
					"<leader>hh",
					function()
						local h = require("harpoon")
						h.ui:toggle_quick_menu(h:list())
					end,
					desc = "Pinned files",
				},
				{
					"<leader>hn",
					function()
						require("harpoon"):list():next()
					end,
					desc = "Next pinned",
				},
				{
					"<leader>hp",
					function()
						require("harpoon"):list():prev()
					end,
					desc = "Previous pinned",
				},
			}
			for i = 1, 4 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
					desc = "Pinned file " .. i,
				})
			end
			return keys
		end,
		opts = {
			settings = {
				save_on_toggle = true,
				-- Key the list by cwd, so each repo keeps its own pins.
				key = function()
					return vim.uv.cwd()
				end,
			},
		},
	},
}
