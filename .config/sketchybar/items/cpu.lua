local colors = require("colors")

local cpu = SBAR.add("item", "cpu", {
	position = "right",
	update_freq = 15,
	icon = {
		string = "􀧓",
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
					local cpu_str = cleaned .. "%"
					local color = get_color(cpu_num)
					cpu:set({
						label = { string = cpu_str },
						icon = { color = color },
					})
				else
					-- Fallback if parsing fails
					cpu:set({ label = { string = cpu_percent } })
				end
			end
		end
	)
end

cpu:subscribe("routine", update_cpu)

update_cpu()

return cpu
