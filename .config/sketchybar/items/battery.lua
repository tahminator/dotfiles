local colors = require("colors")
local font = require("font")

local battery = SBAR.add("item", "battery", {
	position = "right",
	update_freq = 180,
	icon = { string = "bat" },
	-- Fixed width ("100%"): SketchyBar ignores space padding.
	label = { string = "...", width = font.label_width(4), align = "right" },
})

local function update_battery()
	SBAR.exec('pmset -g batt | grep -Eo "\\d+%" | cut -d% -f1', function(percentage_str)
		local percentage = tonumber(percentage_str)

		if not percentage then
			return
		end

		SBAR.exec("pmset -g batt | grep 'AC Power'", function(charging)
			local on_ac = charging ~= ""
			local color

			if percentage > 60 then
				color = on_ac and colors.green or colors.fg
			elseif percentage > 30 then
				color = colors.yellow
			elseif percentage > 10 then
				color = colors.orange
			else
				color = colors.red
			end

			battery:set({
				icon = { string = on_ac and "ac" or "bat" },
				label = { string = percentage .. "%", color = color },
			})
		end)
	end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change" }, update_battery)

update_battery()

return battery
