local memory = SBAR.add("item", "memory", {
	position = "right",
	update_freq = 15,
	icon = {
		string = "􀧖",
	},
})

local function update_mem()
	return SBAR.exec(
		'memory_pressure | grep "System-wide memory free percentage:" | awk \'{ printf("%02.0f\\n", 100-$5"%") }\'',
		function(usage)
			if type(usage) == "string" then
				---@cast usage string
				local usage_str = usage:gsub("%s+", "") .. "%"
				memory:set({ label = { string = usage_str } })
			end
		end
	)
end

memory:subscribe("routine", update_mem)

update_mem()

return memory
