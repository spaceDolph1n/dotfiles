return {
	"nvim-lualine/lualine.nvim",
	-- Icons come from mini.icons, which mocks nvim-web-devicons (plugins/mini.lua).
	dependencies = { "echasnovski/mini.nvim" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- Outer caps, so this bar ends in pills like the tmux one. Same two glyphs
		-- and the same leading/trailing space as @catppuccin_status_left_separator
		-- and _right_separator in tmux.conf, so both bars sit one cell in from the
		-- edge and round off identically. lualine draws a separator with fg set to
		-- its own section's background, so these follow the mode colour on their
		-- own rather than being hardcoded per mode.
		local cap_left = " "
		local cap_right = " "

		lualine.setup({
			options = {
				section_separators = { left = "", right = "" },
				component_separators = "",
			},
			sections = {
				-- a, b, y and z are lualine's own defaults, spelled out only so the
				-- caps have a first and last component to attach to.
				lualine_a = { { "mode", separator = { left = cap_left }, right_padding = 2 } },
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
						color = { fg = "#ff9e64" },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
				lualine_y = { "progress" },
				lualine_z = { { "location", separator = { right = cap_right }, left_padding = 2 } },
			},
		})
	end,
}
