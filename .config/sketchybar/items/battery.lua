local ring = require("ring")

local battery = ring.add("battery", "battery", { update_freq = 180 })

local function update_battery()
	SBAR.exec('pmset -g batt | grep -Eo "\\d+%" | cut -d% -f1', function(percentage_str)
		local percentage = tonumber(percentage_str)
		if not percentage then
			return
		end

		SBAR.exec("pmset -g batt | grep 'AC Power'", function(charging)
			local variant = charging ~= "" and "charging" or percentage <= 20 and "low" or "battery"
			ring.set(battery, variant, percentage)
		end)
	end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change" }, update_battery)
update_battery()

return battery
