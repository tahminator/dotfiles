local calendar = SBAR.add("item", "calendar", {
	position = "right",
	icon = {
		string = "􀧞",
	},
	update_freq = 1,
})

local function update_calendar()
	SBAR.exec("date '+%a %d %b %I:%M:%S %p'", function(date_str)
		if type(date_str) == "string" then
			---@cast date_str string
			calendar:set({ label = { string = date_str } })
		end
	end)
end

calendar:subscribe("routine", update_calendar)

update_calendar()

return calendar
