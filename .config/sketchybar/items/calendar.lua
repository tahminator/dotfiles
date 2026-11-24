local colors = require("colors")
local font = require("font")
local status_gap = require("status_gap")
local clear_text = colors.fg & 0x00ffffff

local members, digits = {}, {}
status_gap("calendar.gap.right")

local function add_part(name, label, icon)
	local item = SBAR.add("item", name, {
		position = "right",
		padding_left = name == "calendar" and 3 or 0,
		padding_right = name == "calendar.period" and 3 or 0,
		icon = icon or { drawing = false },
		label = label,
		background = { color = colors.transparent },
	})
	members[#members + 1] = name
	return item
end

local period = add_part("calendar.period", {
	string = "",
	font = font.medium,
	padding_left = 6,
	padding_right = 8,
})

for i = 8, 1, -1 do
	local separator = i == 3 or i == 6
	local width = separator and 5 or 9
	digits[i] = add_part("calendar.digit." .. i, {
		string = "",
		font = font.medium,
		width = 0,
		align = "left",
		padding_left = -width,
		padding_right = 0,
	}, {
		string = separator and ":" or "",
		font = font.medium,
		width = width,
		align = "left",
		padding_left = 0,
		padding_right = 0,
	})
end

local calendar = add_part("calendar", {
	string = "",
	font = font.text,
	color = colors.muted,
	padding_left = 8,
	padding_right = 6,
})
calendar:set({ update_freq = 1 })
SBAR.add("bracket", "calendar.background", members, {
	background = { color = colors.status, border_color = colors.status_border, border_width = 1, height = 26, corner_radius = 8 },
})
status_gap("calendar.gap.left")

local previous_time, previous_date, previous_period

local function update_calendar()
	local date, time, ampm = os.date("%a %d %b|%I:%M:%S|%p"):match("^(.-)|(.-)|(.-)$")
	if not date then return end
	time = time:gsub("^0", " ")
	if date ~= previous_date then calendar:set({ label = { string = date } }) end
	if ampm ~= previous_period then period:set({ label = { string = ampm } }) end

	for i = 1, 8 do
		local character = time:sub(i, i)
		if i ~= 3 and i ~= 6 and (not previous_time or character ~= previous_time:sub(i, i)) then
			if previous_time then
				digits[i]:set({
					icon = { string = previous_time:sub(i, i), color = colors.fg },
					label = { string = character, color = clear_text },
				})
				SBAR.animate("sin", 24, function()
					digits[i]:set({ icon = { color = clear_text }, label = { color = colors.fg } })
				end)
			else
				digits[i]:set({ icon = { string = character } })
			end
		end
	end
	previous_date, previous_time, previous_period = date, time, ampm
end

calendar:subscribe({ "routine", "system_woke" }, update_calendar)
update_calendar()

return calendar
