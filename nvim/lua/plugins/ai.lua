return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		enabled = false,
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		opts = {
			{
				model = "sonnet-4", -- AI model to use
				temperature = 0.1, -- Lower = focused, higher = creative
				window = {
					layout = "vertical", -- 'vertical', 'horizontal', 'float'
					width = 0.3, -- 50% of screen width
				},
				auto_insert_mode = true, -- Enter insert mode when opening
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- Copilot authorization
			"github/copilot.vim",
			-- Progress options optional
			"franco-ruggeri/codecompanion-spinner.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim", -- Enhanced markdown rendering
				dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
				ft = { "markdown", "codecompanion" },
			},
		},
		config = true,
		lazy = true,
		cmd = {
			"CodeCompanion",
			"CodeCompanionChat",
			"CodeCompanionCmd",
			"CodeCompanionActions",
		},
		keys = {
			{ "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat", mode = { "n", "v" } },
			{ "<leader>ap", "<cmd>CodeCompanionActions<cr>", desc = "Prompt Actions", mode = { "n", "v" } },
		},
		opts = {
			extensions = {
				spinner = {},
			},
			ui = {
				show_model_name = true,
			},
			display = {
				chat = {
					intro_message = "Welcome spaceDolphin ✨! Press ? for options",
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
					roles = {
						llm = function(adapter)
							return "" .. adapter.formatted_name .. "(" .. adapter.model.name .. ")"
						end,
						user = "spaceDolphin",
					},
				},
				inline = {
					adapter = "copilot",
				},
			},
			show_defaults = false,
			adapters = {
				copilot = function()
					-- lua print(vim.inspect(require("codecompanion.adapters").extend("copilot").schema.model.choices()))
					local adapters = require("codecompanion.adapters")
					return adapters.extend("copilot", {
						schema = {
							model = {
								default = "claude-3.7-sonnet",
							},
						},
					})
				end,
			},
			prompt_library = {
				-- Custom the default prompt
				["Generate a Commit Message"] = {
					prompts = {
						{
							role = "user",
							content = function()
								return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
									.. "\n\n```\n"
									.. vim.fn.system("git diff")
									.. "\n```"
							end,
							opts = {
								contains_code = true,
							},
						},
					},
				},
				["Generate a Commit Message for Staged"] = {
					strategy = "chat",
					description = "Generate a commit message for staged change",
					opts = {
						short_name = "staged-commit",
						auto_submit = true,
						is_slash_cmd = true,
					},
					prompts = {
						{
							role = "user",
							content = function()
								return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
									.. "\n\n```\n"
									.. vim.fn.system("git diff --staged")
									.. "\n```"
							end,
							opts = {
								contains_code = true,
							},
						},
					},
				},
			},
		},
	},
}
