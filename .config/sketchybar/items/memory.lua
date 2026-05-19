local colors = require("colors")
local utils = require("utils")
local alpha = require("alpha")

local memory = SBAR.add("graph", "memory", 50, {
	position = "right",
	update_freq = 10,
	icon = {
		string = "􀧖",
	},
	label = {
		string = "0%",
		padding_left = 8,
	},
	graph = {
		color = colors.default.darkGreen,
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
					local color = get_color(usage_num)
					memory:push({ usage_num / 100 })
					memory:set({
						graph = {
							color = color,
						},
						label = { string = cleaned .. "%" },
					})
				end
			end
		end
	)
end

memory:subscribe("routine", update_mem)

update_mem()

return memory
