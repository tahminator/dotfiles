local colors = require("colors")
local utils = require("utils")
local alpha = require("alpha")

local cpu = SBAR.add("graph", "cpu", 50, {
	position = "right",
	update_freq = 10,
	icon = {
		string = "􀧓",
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

local function update_cpu()
	return SBAR.exec(
		"ps -eo pcpu | awk -v core_count=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf \"%.0f\\n\", sum/core_count}'",
		function(cpu_percent)
			if type(cpu_percent) == "string" then
				---@cast cpu_percent string
				local cleaned = cpu_percent:gsub("%s+", "")
				local cpu_num = tonumber(cleaned)

				if cpu_num then
					local color = get_color(cpu_num)
					cpu:push({ cpu_num / 100 })
					cpu:set({
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

cpu:subscribe("routine", update_cpu)

update_cpu()

return cpu
