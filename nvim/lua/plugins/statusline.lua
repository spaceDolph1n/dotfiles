return {
	"nvim-lualine/lualine.nvim",
	-- Icons come from mini.icons, which mocks nvim-web-devicons (plugins/mini.lua).
	dependencies = { "echasnovski/mini.nvim" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- Flat, matching tmux/theme.conf. The backgrounds are `ui.bg` rather than
		-- NONE: kanagawa paints `StatusLine` at #0d0c0c even under
		-- `transparent = true`, so transparent sections left that darker bar
		-- showing between and around them.
		local palette = {
			bg = "#090e13",
			text = "#c5c9c7",
			dim = "#a4a7a4",
			faint = "#5c6066",
		}

		-- One accent per mode, from the roles the tmux bar spends. Only the mode
		-- word takes it, so the bar reads as text rather than blocks.
		local modes = {
			normal = "#8ea4a2",
			insert = "#76946a",
			visual = "#8992a7",
			replace = "#c34043",
			command = "#dca561",
			inactive = "#5c6066",
		}

		local function section(accent)
			return {
				a = { fg = accent, bg = palette.bg, gui = "bold" },
				b = { fg = palette.dim, bg = palette.bg },
				c = { fg = palette.faint, bg = palette.bg },
			}
		end

		local theme = {}
		for mode, accent in pairs(modes) do
			theme[mode] = section(accent)
		end

		lualine.setup({
			options = {
				theme = theme,
				section_separators = "",
				component_separators = "",
			},
			sections = {
				-- Spelled out because lualine's defaults reintroduce separators.
				-- Padding replaces the cap that used to hold the edge.
				lualine_a = { { "mode", padding = { left = 1, right = 2 } } },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#dca561" },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
				lualine_y = { "progress" },
				lualine_z = { { "location", padding = { left = 2, right = 1 } } },
			},
		})
	end,
}
