local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local current_user = os.getenv("USER")
local profile_pic = string.format("/Users/%s/Pictures/profile.jpg", current_user)

local profile = sbar.add("item", "widgets.profile", {
	position = "left",
	background = {
		image = {
			string = profile_pic,
			corner_radius = 5,
			scale = 0.035,
			border_color = colors.transparent,
			border_width = 0,
		},
		drawing = true,
	},
	icon = {
		drawing = false,
	},
	label = {
		drawing = false,
	},
})
