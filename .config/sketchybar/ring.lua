local colors = require("colors")

local home = assert(os.getenv("HOME"))
local directory = home .. "/.cache/sketchybar/rings-v2"
local marker = io.open(directory .. "/wifi-off-100.png", "rb")
if marker then
	marker:close()
else
	local script = home .. "/.config/sketchybar/ring_images.swift"
	assert(os.execute("swift " .. string.format("%q", script) .. " " .. string.format("%q", directory)))
end

local function image(variant, value)
	local percent = math.floor(math.max(0, math.min(100, value)) + 0.5)
	return string.format("%s/%s-%d.png", directory, variant, percent)
end

local M = {}
local states = {}
local frames = 8

function M.add(name, variant, properties)
	properties = properties or {}
	properties.position = "right"
	properties.padding_left = 3
	properties.padding_right = 3
	properties.icon = { drawing = false }
	properties.label = { drawing = false }
	-- Fixed item widths absorb the outer margins; image padding centers the ring.
	properties.background = {
		color = colors.status,
		border_color = colors.status_border,
		border_width = 1,
		height = 26,
		image = { string = image(variant, 0), scale = 0.43, padding_left = 2, padding_right = 2 },
	}
	local item = SBAR.add("item", name, properties)
	states[item] = { value = nil, target = nil, variant = variant, generation = 0 }
	return item
end

function M.set(item, variant, value)
	local state = assert(states[item], "Unknown ring item")
	value = math.max(0, math.min(100, value))
	if state.target == value and state.variant == variant then return end
	state.generation = state.generation + 1
	local generation = state.generation
	local start = state.value
	local changed_variant = state.variant ~= variant
	state.target = value
	state.variant = variant

	if start == nil then
		state.value = value
		item:set({ background = { image = { string = image(variant, value) } } })
		return
	end

	if changed_variant then
		item:set({ background = { image = { string = image(variant, start) }, color = 0x40ffffff } })
		SBAR.animate("sin", 12, function()
			item:set({ background = { color = colors.status } })
		end)
	end

	if start == value then return end
	local frame = 0
	local function advance()
		SBAR.exec("sleep 0.03", function()
			if state.generation ~= generation then return end
			frame = frame + 1
			local t = frame / frames
			local eased = t * t * (3 - 2 * t)
			state.value = start + (value - start) * eased
			item:set({ background = { image = { string = image(variant, state.value) } } })
			if frame < frames then advance() end
		end)
	end
	advance()
end

return M
