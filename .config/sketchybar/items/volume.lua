local ring = require("ring")

local volume = ring.add("volume", "volume")

local function update_volume(value)
	local percent = tonumber(value)
	if percent then
		ring.set(volume, percent == 0 and "mute" or "volume", percent)
	end
end

volume:subscribe("volume_change", function(env)
	update_volume(env.INFO)
end)

SBAR.exec("osascript -e 'if output muted of (get volume settings) then return 0' -e 'return output volume of (get volume settings)'", update_volume)

return volume
