local sparkline = require("sparkline")

local memory = SBAR.add("item", "memory", {
	position = "right",
	update_freq = 10,
	icon = { string = "mem" },
	label = { string = "...", width = sparkline.label.width, align = sparkline.label.align },
})

local push = sparkline.new()

local function update_mem()
	return SBAR.exec(
		'memory_pressure | grep "System-wide memory free percentage:" | awk \'{ printf("%02.0f\\n", 100-$5"%") }\'',
		function(usage)
			if type(usage) == "string" then
				---@cast usage string
				local usage_num = tonumber((usage:gsub("%s+", "")))

				if usage_num then
					local text, color = push(usage_num)
					memory:set({ label = { string = text, color = color } })
				end
			end
		end
	)
end

memory:subscribe("routine", update_mem)

update_mem()

return memory
