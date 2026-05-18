local wifi = SBAR.add("item", "wifi", {
	position = "right",
	icon = {
		string = "􀙥",
	},
	label = {
		string = "Waiting...",
	},
})

wifi:subscribe({ "routine", "wifi_change" }, function()
	SBAR.exec(
		'system_profiler SPAirPortDataType | awk \'/Current Network Information:/ { getline; getline; getline; getline; getline; getline; getline; split($0, a, ": "); split(a[2], b, " /"); print b[1]; exit }\'',
		function(dbm)
			if type(dbm) == "string" then
				---@cast dbm string
				wifi:set({
					icon = { string = "􀙇" },
					label = { string = dbm:gsub("%s+", " ") },
				})
			end
		end
	)
end)

return wifi
