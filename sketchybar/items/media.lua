local icons = require("icons")
local colors = require("colors")

-- Updated whitelist with Chrome instead of Brave
local whitelist = {
	["^Spotify$"] = true, -- Exact match for Spotify
	["^Google Chrome$"] = true, -- Exact match for Chrome
	["^Zen Browser$"] = true, -- Exact match for Chrome
}

local function is_whitelisted(app_name)
	for pattern in pairs(whitelist) do
		if string.match(app_name, pattern) then
			return true
		end
	end
	return false
end

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	background = {
		image = {
			string = "media.artwork",
			scale = 0.85, -- Default scale
		},
		color = colors.transparent,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = true, -- Always show the media cover
	updates = true,
	name = "media.cover",
})

local media_artist = sbar.add("item", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 18,
		y_offset = 6,
	},
})

local media_title = sbar.add("item", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		width = 0,
		max_chars = 16,
		y_offset = -5,
	},
})

local is_playing = false

local function animate_labels(show)
	sbar.animate("tanh", 30, function()
		media_artist:set({ label = { width = show and "dynamic" or 0 } })
		media_title:set({ label = { width = show and "dynamic" or 0 } })
	end)
end

media_cover:subscribe("media_change", function(env)
	if is_whitelisted(env.INFO.app) then
		local has_artist = env.INFO.artist ~= ""
		local has_title = env.INFO.title ~= ""
		local drawing = has_artist or has_title
		local was_playing = is_playing
		is_playing = env.INFO.state == "playing"

		-- Determine if it's a YouTube video playing in Chrome
		local is_youtube = env.INFO.url and string.match(env.INFO.url, "youtube%.com")
		local target_scale = 0.85 -- Default scale for most apps
		if is_youtube then
			target_scale = 1.0 -- Larger scale for YouTube
		end

		-- Always show the media cover
		media_cover:set({
			drawing = true,
			background = {
				image = {
					string = "media.artwork",
				},
			},
		})

		-- For YouTube videos, use the video title as the "song name"
		local title = env.INFO.title
		if is_youtube then
			title = env.INFO.title -- Use the video title directly
		end

		-- Only show artist and title if they exist
		media_artist:set({ drawing = has_artist, label = env.INFO.artist })
		media_title:set({ drawing = has_title, label = title })

		-- Animate labels when play state changes
		if is_playing ~= was_playing then
			animate_labels(is_playing)
		end
	else
		-- Hide artist and title if the app is not whitelisted
		media_artist:set({ drawing = false })
		media_title:set({ drawing = false })
	end
end)

media_cover:subscribe("mouse.entered", function(env)
	if not is_playing then
		animate_labels(true)
	end
end)

media_cover:subscribe("mouse.exited", function(env)
	if not is_playing then
		animate_labels(false)
	end
end)
