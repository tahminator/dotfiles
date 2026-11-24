local colors = require("colors")
local font = require("font")
local icon_map = require("icon_map")
local wm = require("wm")

---@type table<string, SbarItem>
local items = {}
local previous_order
local has_group = false
local focused_id
local transition = 0
local pending_focus
local displayed_focus
local retained_focus
local retiring_focus
local visible = {}

local function quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function release_retiring()
	if retiring_focus and items[retiring_focus] then
		items[retiring_focus]:set({
			width = "dynamic",
			icon = { color = colors.muted },
			label = { color = colors.muted },
		})
	end
	retiring_focus = nil
end

local function retire_empty(from, generation, width)
	SBAR.exec("sleep 0.2", function()
		if generation ~= transition or retiring_focus ~= from or not items[from] then return end
		if not width then
			items[from]:set({ drawing = false })
			release_retiring()
			return
		end
		items[from]:set({ width = width })
		SBAR.animate("sin", 12, function()
			items[from]:set({ width = 0, icon = { color = colors.transparent }, label = { color = colors.transparent } })
		end)
		SBAR.exec("sleep 0.25", function()
			if generation ~= transition or retiring_focus ~= from or not items[from] then return end
			items[from]:set({ drawing = false })
			release_retiring()
		end)
	end)
end

local function slide_selection(from, to, generation)
	SBAR.exec("sketchybar --query " .. quote("space." .. from), function(source)
		if generation ~= transition or focused_id ~= to or not items[to] then
			return
		end
		-- Keep an empty source in the layout until the selection has slid.
		SBAR.exec("sketchybar --query " .. quote("space." .. to), function(target)
			if generation ~= transition or focused_id ~= to or not items[to] then
				return
			end
			pending_focus = nil
			retained_focus = nil
			local offset, source_width = 0, nil
			if type(source) == "table" and type(target) == "table" then
				local old_rects, new_rects = source.bounding_rects, target.bounding_rects
				if type(old_rects) == "table" and type(new_rects) == "table" then
					local background = source.geometry and source.geometry.background
					local current_offset = background and tonumber(background.x_offset) or 0
					for display, old in pairs(old_rects) do
						local new = new_rects[display]
						if new and old.origin and new.origin and old.origin[1] ~= -9999 and new.origin[1] ~= -9999 then
							offset = math.floor(old.origin[1] + current_offset - new.origin[1] + 0.5)
							if old.size and old.size[1] then
								local geometry = source.geometry or {}
								source_width = old.size[1] + (tonumber(geometry.padding_left) or 0)
									+ (tonumber(geometry.padding_right) or 0)
							end
							break
						end
					end
				end
			end
			if items[from] then
				items[from]:set({ background = { color = colors.transparent, border_color = colors.transparent } })
			end
			displayed_focus = to
			if items[from] and not visible[from] then retiring_focus = from end
			items[to]:set({ background = { color = colors.selection, border_color = colors.selection_border, x_offset = offset } })
			SBAR.animate("sin", 12, function()
				items[to]:set({ background = { x_offset = 0 } })
			end)
			if retiring_focus == from then retire_empty(from, generation, source_width) end
		end)
	end)
end

---@param ws WMWorkspace
local function create_space(ws)
	-- Ordinary items: WM workspace IDs are not native macOS Space IDs.
	local item = SBAR.add("item", "space." .. ws.id, {
		position = "left",
		drawing = false,
		icon = { string = ws.label },
		label = { font = font.apps },
		background = { height = 22, corner_radius = 7, border_width = 1 },
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
	local previous_focus = focused_id
	focused_id = nil
	for _, ws in ipairs(state.workspaces) do
		if ws.focused then focused_id = ws.id end
		visible[ws.id] = ws.focused or #ws.apps > 0
	end
	if previous_focus ~= focused_id then
		release_retiring()
		transition = transition + 1
		pending_focus = displayed_focus and focused_id ~= displayed_focus and focused_id or nil
		retained_focus = pending_focus and displayed_focus or nil
		if not pending_focus then displayed_focus = focused_id end
	end
	if retiring_focus and visible[retiring_focus] then release_retiring() end
	for _, ws in ipairs(state.workspaces) do
		local item = items[ws.id] or create_space(ws)
		seen[ws.id] = true
		ordered[#ordered + 1] = "space." .. ws.id
		local text = ws.focused and colors.fg or colors.muted
		item:set({
			drawing = visible[ws.id] or ws.id == retained_focus or ws.id == retiring_focus,
			display = ws.display,
			icon = { string = ws.label, color = text },
			label = { string = icon_strip(ws.apps), color = text },
			background = {
				color = ws.id == displayed_focus and colors.selection or colors.transparent,
				border_color = ws.id == displayed_focus and colors.selection_border or colors.transparent,
			},
		})
	end
	for id, item in pairs(items) do
		if not seen[id] then
			SBAR.remove(item.name)
			visible[id] = nil
			items[id] = nil
		end
	end
	local members = { table.unpack(ordered) }
	table.insert(ordered, 1, "front_app")
	local quoted = {}
	for _, name in ipairs(ordered) do
		quoted[#quoted + 1] = quote(name)
	end
	local order = table.concat(quoted, " ")
	if order ~= previous_order then
		SBAR.exec("sketchybar --reorder " .. order)
		previous_order = order
		-- Recessed track behind the workspace strip.
		if has_group then
			SBAR.remove("spaces")
		end
		has_group = #members > 0
		if has_group then
			SBAR.add("bracket", "spaces", members, { background = { color = colors.recess, height = 26, corner_radius = 8 } })
		end
	end
	if pending_focus and previous_focus ~= focused_id then
		slide_selection(displayed_focus, focused_id, transition)
	end
end)

return items
