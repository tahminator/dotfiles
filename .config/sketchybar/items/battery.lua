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

			if charging ~= "" then
				icon = "􀢋"
				color = colors.legacy.item
			elseif percentage >= 90 then
				icon = "􀛨"
				color = colors.legacy.item
			elseif percentage >= 60 then
				icon = "􀺸"
				color = colors.legacy.item
			elseif percentage >= 30 then
				icon = "􀺶"
				color = 0xFFd97706
			elseif percentage >= 10 then
				icon = "􀛩"
				color = 0xFFf97316
			else
				icon = "􀛪"
				color = 0xFFef4444
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
