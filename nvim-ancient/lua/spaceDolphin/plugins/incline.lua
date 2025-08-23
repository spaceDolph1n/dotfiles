return {
	"b0o/incline.nvim",
	event = "VeryLazy",
	config = function()
		local helpers = require("incline.helpers")
		local devicons = require("nvim-web-devicons")
		require("incline").setup({
			highlight = {
				groups = {
					InclineNormal = { guibg = "none", guifg = "#D9E0EE" },
					InclineNormalNC = { guibg = "none", guifg = "#a9b1d6" },
				},
			},
			window = {
				margin = {
					horizontal = 2,
					vertical = 2,
				},
				options = {
					signcolumn = "no",
					wrap = false,
				},
				overlap = {
					borders = true,
					statusline = false,
					tabline = false,
					winbar = false,
				},
				padding = 0,
				padding_char = " ",
				placement = {
					horizontal = "right",
					vertical = "top",
				},
				width = "fit",
				winhighlight = {
					active = {
						EndOfBuffer = "None",
						Normal = "InclineNormal",
						Search = "None",
					},
					inactive = {
						EndOfBuffer = "None",
						Normal = "InclineNormalNC",
						Search = "None",
					},
				},
				zindex = 50,
			},
			render = function(props)
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
				if filename == "" then
					filename = "[No Name]"
				end
				local ft_icon, ft_color = devicons.get_icon_color(filename)
				local modified = vim.bo[props.buf].modified
				return {
					ft_icon and { "", guifg = ft_color },
					ft_icon and { ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
					{ " ", filename, " ", guibg = "#313244", gui = modified and "bold,italic" or "bold" },
					{ "", guifg = "#313244" },
				}
			end,
		})
	end,
}
