local colors = require("colors")
local font = require("font")

local volume = SBAR.add("item", "volume", {
	position = "right",
	icon = { string = "vol" },
	-- Fixed width ("100%", "mute"): SketchyBar ignores space padding.
	label = { string = "...", width = font.label_width(4), align = "right" },
})

volume:subscribe("volume_change", function(env)
	local volume_percent = tonumber(env.INFO)

	if volume_percent then
		volume:set({
			label = volume_percent == 0 and { string = "mute", color = colors.muted }
				or { string = volume_percent .. "%", color = colors.fg },
		})
	end
end)

return volume
