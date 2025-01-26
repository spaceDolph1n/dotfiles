return {
	-- Base colors
	black = 0xff1e1e2e, -- Base (Darkest)
	white = 0xffcdd6f4, -- Text (Lightest)
	red = 0xfff38ba8, -- Red
	green = 0xffa6e3a1, -- Green
	blue = 0xff89b4fa, -- Blue
	yellow = 0xfff9e2af, -- Yellow
	orange = 0xfffab387, -- Peach
	magenta = 0xffcba6f7, -- Mauve
	grey = 0xff585b70, -- Overlay2
	teal = 0xff94e2d5, -- Teal
	purple = 0xffb4befe, -- Lavender
	transparent = 0x00000000, -- Transparent

	-- Bar colors
	bar = {
		bg = 0xe61e1e2e, -- Base (Darkest)
		border = 0xff313244, -- Surface0
	},

	-- Popup colors
	popup = {
		bg = 0xe61e1e2e, -- Base (Darkest)
		border = 0xff585b70, -- Overlay2
	},

	-- Spaces colors
	spaces = {
		active = 0xff89b4fa, -- Blue
		inactive = 0x00313244, -- Surface0 (Transparent)
	},

	-- Background colors
	bg1 = 0xff1e1e2e, -- Base (Darkest)
	bg2 = 0xff313244, -- Surface0

	-- Utility function to add alpha to a color
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
