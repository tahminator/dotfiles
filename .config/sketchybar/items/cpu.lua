local sparkline = require("sparkline")

local cpu, push = sparkline.new("cpu", "\u{f061a}")

local function update_cpu()
	return SBAR.exec(
		"ps -eo pcpu | awk -v core_count=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf \"%.0f\\n\", sum/core_count}'",
		function(cpu_percent)
			if type(cpu_percent) == "string" then
				---@cast cpu_percent string
				local cpu_num = tonumber((cpu_percent:gsub("%s+", "")))

				if cpu_num then
					push(cpu_num)
				end
			end
		end
	)
end

cpu:subscribe("routine", update_cpu)

update_cpu()

return cpu
