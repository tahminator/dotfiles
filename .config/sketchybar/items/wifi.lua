local ring = require("ring")

local wifi = ring.add("wifi", "wifi", { update_freq = 120 })

local function update_wifi()
	SBAR.exec(
		'system_profiler SPAirPortDataType | awk \'/Current Network Information:/ { getline; getline; getline; getline; getline; getline; getline; split($0, a, ": "); split(a[2], b, " /"); print b[1]; exit }\'',
		function(dbm)
			if type(dbm) == "string" then
				local signal = tonumber(dbm:match("%-?%d+"))
				ring.set(wifi, signal and "wifi" or "wifi-off", signal and (signal + 90) * 2.5 or 0)
			end
		end
	)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, update_wifi)
update_wifi()

return wifi
