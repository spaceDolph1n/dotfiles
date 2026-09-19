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
			bg = "#090b10",
			text = "#e0def4",
			dim = "#908caa",
			faint = "#6e6a86",
		}

		-- One accent per mode, from the roles the tmux bar spends. Only the mode
		-- word takes it, so the bar reads as text rather than blocks.
		local modes = {
			normal = "#9ccfd8",
			insert = "#9ccfd8",
			visual = "#31748f",
			replace = "#eb6f92",
			command = "#ebbcba",
			inactive = "#6e6a86",
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
						color = { fg = "#f6c177" },
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
