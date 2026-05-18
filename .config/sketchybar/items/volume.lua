local volume = SBAR.add("item", "volume", {
	position = "right",
})

volume:subscribe("volume_change", function(env)
	local volume_percent = tonumber(env.INFO)

	if volume_percent then
		local icon
		if volume_percent >= 60 then
			icon = "􀊩"
		elseif volume_percent >= 30 then
			icon = "􀊥"
		elseif volume_percent >= 1 then
			icon = "􀊡"
		else
			icon = "􀊣"
		end

		volume:set({
			icon = { string = icon },
			label = { string = volume_percent .. "%" },
		})
	end
end)

return volume
