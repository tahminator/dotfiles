local sparkline = require("sparkline")

local memory, push = sparkline.new("memory", "\u{f035b}")

local function update_mem()
	return SBAR.exec(
		'memory_pressure | grep "System-wide memory free percentage:" | awk \'{ printf("%02.0f\\n", 100-$5"%") }\'',
		function(usage)
			if type(usage) == "string" then
				---@cast usage string
				local usage_num = tonumber((usage:gsub("%s+", "")))

				if usage_num then
					push(usage_num)
				end
			end
		end
	)
end

memory:subscribe("routine", update_mem)

update_mem()

return memory
