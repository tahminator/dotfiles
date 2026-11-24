package.path = "./?.lua;./?/init.lua;" .. package.path

local items, callbacks, animations = {}, {}, 0
SBAR = {
	add = function(kind, name, props, graph_props)
		if kind == "bracket" then return {} end
		local item = { name = name, props = graph_props or props, updates = {}, samples = {} }
		function item:set(update) self.updates[#self.updates + 1] = update end
		function item:subscribe(_, callback) self.callback = callback end
		function item:push(values) self.samples[#self.samples + 1] = values end
		items[name] = item
		return item
	end,
	exec = function(_, callback) callbacks[#callbacks + 1] = callback end,
	animate = function(_, _, callback) animations = animations + 1; callback() end,
}

local open = io.open
io.open = function() return { close = function() end } end
local ring = require("ring")
io.open = open
local volume = ring.add("volume", "volume")
local function last_image(item)
	for i = #item.updates, 1, -1 do
		local background = item.updates[i].background
		if background and background.image then return background.image.string end
	end
end

ring.set(volume, "volume", 20)
assert(last_image(volume):match("/volume%-20%.png$"))
ring.set(volume, "volume", 80)
callbacks[1]()
assert(last_image(volume):match("/volume%-23%.png$"))
ring.set(volume, "volume", 10)
local count = #volume.updates
callbacks[2]()
assert(#volume.updates == count, "stale frame changed the ring")
for i = 3, 10 do callbacks[i]() end
assert(last_image(volume):match("/volume%-10%.png$"))
ring.set(volume, "volume", 10)
assert(#callbacks == 10, "unchanged values scheduled animation")
ring.set(volume, "mute", 10)
assert(last_image(volume):match("/mute%-10%.png$"))

local date = os.date
local current = "Tue 24 Nov|02:09:59|AM"
os.date = function() return current end
require("items.calendar")
local tick = items.calendar.callback
local before = animations
tick()
assert(animations == before, "unchanged digits animated")
current = "Tue 24 Nov|02:10:00|AM"
tick()
assert(animations - before == 4, "only the four changed digits should animate")
local transition = items["calendar.digit.7"].updates
local start, finish = transition[#transition - 1], transition[#transition]
assert(start.icon.string == "5" and start.label.string == "0")
assert(start.label.y_offset == nil and finish.label.y_offset == nil, "digits must not slide")
local fg = require("colors").fg
assert(start.icon.color == fg and start.label.color == (fg & 0x00ffffff), "old digit must remain visible")
assert(finish.icon.color == (fg & 0x00ffffff) and finish.label.color == fg, "digits must crossfade")
current = "Tue 24 Nov|12:00:00|PM"
tick()
assert(items["calendar.period"].updates[#items["calendar.period"].updates].label.string == "PM")

local graph, push = require("sparkline").new("test.metric", "x")
push(9)
assert(items["test.metric.value.3"].updates[1].icon.string == "9")
local before_metrics = animations
push(10)
assert(animations - before_metrics == 2, "only changed metric digits should animate")
local ones = items["test.metric.value.3"].updates
local old, new = ones[#ones - 1], ones[#ones]
assert(old.icon.string == "9" and old.label.string == "0")
assert(old.icon.color == require("colors").green and old.label.color == (require("colors").green & 0x00ffffff))
assert(new.icon.color == (require("colors").green & 0x00ffffff) and new.label.color == require("colors").green)
push(10)
assert(animations - before_metrics == 2, "unchanged metric digits must not animate")
assert(#graph.samples == 3 and #graph.samples[1] == 48 and #graph.samples[2] == 4)
os.date = date
print("UI animation tests passed")
