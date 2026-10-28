local colors = require("colors")
local font = require("font")
local icon_map = require("icon_map")
local wm = require("wm")

---@type table<string, SbarItem>
local items = {}
local previous_order
local has_group = false

---@param ws WMWorkspace
local function create_space(ws)
	-- Ordinary items: WM workspace IDs are not native macOS Space IDs.
	local item = SBAR.add("item", "space." .. ws.id, {
		position = "left",
		drawing = false,
		icon = { string = ws.label },
		label = { font = font.apps },
		-- Inset 3pt (item padding) inside the group pill, with a matching smaller radius.
		background = { height = 18, corner_radius = 3 },
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
		-- The focused workspace is inverted, like Ghostty's block cursor.
		local text = ws.focused and colors.black or colors.muted
		item:set({
			drawing = ws.focused or #ws.apps > 0,
			display = ws.display or "all",
			icon = { string = ws.label, color = text },
			label = { color = text },
			background = { color = ws.focused and colors.fg or colors.transparent },
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
	local members = { table.unpack(ordered) }
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
		-- One glass pill behind the whole workspace strip.
		if has_group then
			SBAR.remove("spaces")
		end
		has_group = #members > 0
		if has_group then
			SBAR.add("bracket", "spaces", members, { background = { color = colors.glass } })
		end
	end
end)

return items
