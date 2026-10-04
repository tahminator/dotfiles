local sparkline = require("sparkline")

local cpu = SBAR.add("item", "cpu", {
	position = "right",
	update_freq = 10,
	icon = { string = "cpu" },
	label = { string = "...", width = sparkline.label.width, align = sparkline.label.align },
})

local push = sparkline.new()

local function update_cpu()
	return SBAR.exec(
		"ps -eo pcpu | awk -v core_count=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf \"%.0f\\n\", sum/core_count}'",
		function(cpu_percent)
			if type(cpu_percent) == "string" then
				---@cast cpu_percent string
				local cpu_num = tonumber((cpu_percent:gsub("%s+", "")))

				if cpu_num then
					local text, color = push(cpu_num)
					cpu:set({ label = { string = text, color = color } })
				end
			end
		end
	)
end

cpu:subscribe("routine", update_cpu)

update_cpu()

return cpu
