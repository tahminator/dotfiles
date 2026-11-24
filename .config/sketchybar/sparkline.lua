local colors = require("colors")
local font = require("font")
local status_gap = require("status_gap")

local width = 48
local steps = 4

local M = {}

function M.new(name, icon)
	status_gap(name .. ".gap.right")
	local digits, members, layers = {}, {}, {}
	for i = 3, 1, -1 do
		local digit_width = i == 3 and 17 or 9
		local digit_name = name .. ".value." .. i
		digits[i] = SBAR.add("item", digit_name, {
			position = "right",
			padding_left = i == 1 and 6 or 0,
			padding_right = i == 3 and 3 or 0,
			icon = { string = "", font = font.medium, width = digit_width, align = "left", padding_left = 0, padding_right = 0 },
			label = { string = "", font = font.medium, width = 0, align = "left", padding_left = -digit_width, padding_right = 0 },
			background = { color = colors.transparent },
		})
		members[#members + 1] = digit_name
	end

	local graph = SBAR.add("graph", name, width, {
		position = "right",
		update_freq = 10,
		padding_left = 3,
		padding_right = 0,
		icon = { string = icon, font = font.symbols },
		label = { drawing = false },
		background = { color = colors.transparent, border_color = colors.transparent, border_width = 1, height = 26 },
		graph = { color = colors.green, fill_color = colors.transparent, line_width = 1 },
	})
	members[#members + 1] = name
	SBAR.add("bracket", name .. ".background", members, {
		background = { color = colors.status, border_color = colors.status_border, border_width = 1, height = 26, corner_radius = 8 },
	})
	status_gap(name .. ".gap.left")

	local previous, previous_text, previous_color

	local function push(percent)
		percent = math.max(0, math.min(100, percent))
		local color = percent <= 50 and colors.green or percent <= 75 and colors.yellow or colors.red
		local text = string.format("%3d", math.floor(percent + 0.5))
		local value = 0.08 + percent * 0.0084
		local samples = {}
		if previous == nil then
			for i = 1, width do samples[i] = value end
		else
			for i = 1, steps do
				local t = i / steps
				local eased = t * t * (3 - 2 * t)
				samples[i] = previous + (value - previous) * eased
			end
		end

		for i = 1, 3 do
			local character = text:sub(i, i)
			if not previous_text then
				digits[i]:set({ icon = { string = character, color = color } })
				layers[i] = "icon"
			elseif character ~= previous_text:sub(i, i) then
				digits[i]:set({
					icon = { string = previous_text:sub(i, i), color = previous_color },
					label = { string = character, color = color & 0x00ffffff },
				})
				SBAR.animate("sin", 24, function()
					digits[i]:set({ icon = { color = previous_color & 0x00ffffff }, label = { color = color } })
				end)
				layers[i] = "label"
			elseif color ~= previous_color then
				digits[i]:set({ [layers[i]] = { color = color } })
			end
		end
		previous, previous_text, previous_color = value, text, color
		graph:set({ graph = { color = color } })
		graph:push(samples)
	end

	return graph, push
end

return M
