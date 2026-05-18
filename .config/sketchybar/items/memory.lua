local colors = require("colors")

local memory = SBAR.add("item", "memory", {
	position = "right",
	update_freq = 15,
	icon = {
		string = "􀧖",
	},
})

local function get_color(percent)
	if percent <= 50 then
		return colors.default.darkGreen
	elseif percent <= 75 then
		return colors.default.yellow
	else
		return colors.default.red
	end
end

local function update_mem()
	return SBAR.exec(
		'memory_pressure | grep "System-wide memory free percentage:" | awk \'{ printf("%02.0f\\n", 100-$5"%") }\'',
		function(usage)
			if type(usage) == "string" then
				---@cast usage string
				local cleaned = usage:gsub("%s+", "")
				local usage_num = tonumber(cleaned)

				if usage_num then
					local usage_str = cleaned .. "%"
					local color = get_color(usage_num)
					memory:set({
						label = { string = usage_str },
						icon = { color = color },
					})
				else
					-- Fallback if parsing fails
					memory:set({ label = { string = usage } })
				end
			end
		end
	)
end

memory:subscribe("routine", update_mem)

update_mem()

return memory
