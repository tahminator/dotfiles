local cpu = SBAR.add("item", "cpu", {
	position = "right",
	update_freq = 15,
	icon = {
		string = "􀧓",
	},
})

local function update_cpu()
	return SBAR.exec(
		"ps -eo pcpu | awk -v core_count=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf \"%.0f\\n\", sum/core_count}'",
		function(cpu_percent)
			if type(cpu_percent) == "string" then
				---@cast cpu_percent string
				cpu:set({ label = { string = cpu_percent:gsub("%s+", "") .. "%" } })
			end
		end
	)
end

cpu:subscribe("routine", update_cpu)

update_cpu()

return cpu
