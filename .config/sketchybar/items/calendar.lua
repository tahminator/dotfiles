local calendar = SBAR.add("item", "calendar", {
	position = "right",
	update_freq = 1,
})

local function update_calendar()
	SBAR.exec("date '+%a %d %b|%I:%M:%S %p'", function(date_str)
		if type(date_str) == "string" then
			---@cast date_str string
			local date, time = date_str:match("^(.-)|(.-)%s*$")
			if date then
				calendar:set({ icon = { string = date }, label = { string = time } })
			end
		end
	end)
end

calendar:subscribe("routine", update_calendar)

update_calendar()

return calendar
