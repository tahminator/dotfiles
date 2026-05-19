local colors = require("colors")

local battery = SBAR.add("item", "battery", {
	position = "right",
	update_freq = 180,
})

local function update_battery()
	SBAR.exec('pmset -g batt | grep -Eo "\\d+%" | cut -d% -f1', function(percentage_str)
		local percentage = tonumber(percentage_str)

		if not percentage then
			return
		end

		SBAR.exec("pmset -g batt | grep 'AC Power'", function(charging)
			local icon
			local color

			if percentage > 50 then
				color = nil
			elseif percentage > 30 then
				color = colors.ios.yellow
			elseif percentage > 10 then
				color = colors.ios.orange
			else
				color = colors.ios.deepRed
			end

			if charging ~= "" then
				icon = "􀢋"
			elseif percentage > 50 then
				icon = "􀛨"
			elseif percentage > 30 then
				icon = "􀛨"
			elseif percentage > 10 then
				icon = "􀺶"
			else
				icon = "􀛪"
			end

			battery:set({
				icon = { string = icon, color = color },
				label = { string = percentage .. "%" },
			})
		end)
	end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change" }, update_battery)

update_battery()

return battery
