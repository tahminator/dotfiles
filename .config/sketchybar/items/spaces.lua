local colors = require("colors")
local icon_map = require("icon_map")
local wm = require("wm")

---@type table<string, SbarItem>
local items = {}
local previous_order

---@param ws WMWorkspace
local function create_space(ws)
	-- Ordinary items: WM workspace IDs are not native macOS Space IDs.
	local item = SBAR.add("item", "space." .. ws.id, {
		position = "left",
		drawing = false,
		icon = {
			string = ws.label,
			color = colors.legacy.accent,
			font = { family = "Monocraft Nerd Font", style = "Semibold", size = 14.0 },
			y_offset = 1,
		},
		label = {
			color = colors.legacy.accent,
			font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
			padding_right = 10,
			y_offset = -1,
		},
		background = { color = colors.legacy.transparent },
	})
	item:subscribe("mouse.clicked", function(env)
		wm.activate_workspace(ws.id, env.BUTTON)
	end)
	items[ws.id] = item
	return item
end

---@param apps string[]
local function icon_strip(apps)
	local seen, sorted = {}, {}
	for _, app in ipairs(apps) do
		if app ~= "" and not seen[app] then
			seen[app] = true
			sorted[#sorted + 1] = app
		end
	end
	table.sort(sorted)
	if #sorted == 0 then
		return " —"
	end
	local strip = ""
	for _, app in ipairs(sorted) do
		strip = strip .. " " .. (icon_map[app] or ":default:")
	end
	return strip
end

wm.subscribe(function(state)
	local seen, ordered = {}, {}
	for _, ws in ipairs(state.workspaces) do
		local item = items[ws.id] or create_space(ws)
		seen[ws.id] = true
		ordered[#ordered + 1] = "space." .. ws.id
		item:set({
			drawing = ws.focused or #ws.apps > 0,
			display = ws.display or "all",
			icon = { string = ws.label },
			background = { color = ws.focused and colors.bar.tertiary or colors.legacy.transparent },
		})
		SBAR.animate("sin", 10, function()
			item:set({ label = { string = icon_strip(ws.apps) } })
		end)
	end
	for id, item in pairs(items) do
		if not seen[id] then
			SBAR.remove(item.name)
			items[id] = nil
		end
	end
	-- Async workspace creation must not place spaces after the front-app item.
	ordered[#ordered + 1] = "front_app"
	local quoted = {}
	for _, name in ipairs(ordered) do
		quoted[#quoted + 1] = "'" .. name:gsub("'", "'\\''") .. "'"
	end
	local order = table.concat(quoted, " ")
	if order ~= previous_order then
		SBAR.exec("sketchybar --reorder " .. order)
		previous_order = order
	end
end)

return items
