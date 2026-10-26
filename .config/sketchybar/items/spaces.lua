local font = require("font")
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
		-- Half a character cell after each workspace.
		padding_right = font.cell // 2,
		icon = { string = ws.label },
		label = { font = font.apps },
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
		-- The current workspace is bracketed, "[3]"; the fixed width keeps
		-- neighbours from shifting when focus moves.
		item:set({
			drawing = ws.focused or #ws.apps > 0,
			display = ws.display or "all",
			icon = {
				string = ws.focused and "[" .. ws.label .. "]" or ws.label,
				width = font.label_width(#ws.label + 2),
				align = "center",
			},
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
