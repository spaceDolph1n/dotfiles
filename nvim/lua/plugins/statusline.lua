return {
	"nvim-lualine/lualine.nvim",
	-- Icons come from mini.icons, which mocks nvim-web-devicons (plugins/mini.lua).
	dependencies = { "echasnovski/mini.nvim" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		-- Outer caps, matching the separators in tmux.conf so both bars round off
		-- identically. lualine sets separator fg from its own section background,
		-- so they follow the mode colour without being hardcoded per mode.
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
