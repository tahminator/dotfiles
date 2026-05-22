-- ripped from @pyrorhythm, restyled after spaces.lua

local colors = require("colors")
local icon_map = require("icon_map")

---@type RiftAPI
local rift = require("riftapi")

local WS_LABELS = {
	"",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"A",
	"C",
	"D",
	"E",
	"G",
	"I",
	"M",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"U",
	"W",
	"X",
	"Y",
	"Z",
}

local MAX_WS = #WS_LABELS

local function ws_label(i)
	return WS_LABELS[i + 1] or tostring(i + 1)
end

---@type table<integer, SBARItem>
local items = {}

local function name_item(i)
	return "rift.ws." .. i
end

---@param i integer  0-based workspace index
---@param is_focused boolean
local function set_focus_appearance(i, is_focused)
	SBAR.set(name_item(i), {
		background = { color = is_focused and colors.bar.tertiary or colors.legacy.transparent },
		icon = { color = colors.legacy.accent },
		label = { color = colors.legacy.accent },
	})
end

---@param ws RiftWorkspace
local function refresh_icons(ws)
	local wins = ws.windows or {}
	local seen, apps = {}, {}
	for _, win in ipairs(wins) do
		local app = win.app_name or ""
		if app ~= "" and not seen[app] then
			seen[app] = true
			apps[#apps + 1] = app
		end
	end
	table.sort(apps)

	local strip = " —"
	if #apps > 0 then
		strip = ""
		for _, app in ipairs(apps) do
			strip = strip .. " " .. (icon_map[app] or ":default:")
		end
	end

	SBAR.animate("sin", 10, function()
		SBAR.set(name_item(ws.index), { label = { string = strip } })
	end)
end

local function build_pool()
	for i = 0, MAX_WS - 1 do
		local item = SBAR.add("item", name_item(i), {
			drawing = false,
			position = "left",
			icon = {
				string = ws_label(i),
				color = colors.legacy.accent,
				font = { family = "Monocraft Nerd Font", style = "Semibold", size = 14.0 },
				y_offset = 1,
			},
			label = {
				string = " —",
				color = colors.legacy.accent,
				font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
				padding_right = 10,
				y_offset = -1,
			},
			background = { color = colors.legacy.transparent },
		})
		item:subscribe("mouse.clicked", function(env)
			if env.BUTTON == "right" then
				rift.workspace.create()
			else
				rift.workspace.switch(i)
			end
		end)
		items[i] = item
	end
end

---@param ws_list RiftWorkspace[]
local function render(ws_list)
	local seen = {}
	for _, ws in ipairs(ws_list) do
		local i = ws.index
		seen[i] = true
		local is_empty = not ws.windows or #ws.windows == 0
		if not ws.is_active and is_empty then
			SBAR.set(name_item(i), { drawing = false })
		else
			SBAR.set(name_item(i), { drawing = true })
			set_focus_appearance(i, ws.is_active)
			refresh_icons(ws)
		end
	end
	for i = 0, MAX_WS - 1 do
		if not seen[i] then
			SBAR.set(name_item(i), { drawing = false })
		end
	end
end

local function refresh()
	local ws_list, err = rift.query.workspaces()
	if not ws_list then
		print("[rift] " .. tostring(err))
		return
	end
	render(ws_list)
end

SBAR.delay(0.5, function()
	build_pool()

	local watcher = SBAR.add("item", "rift.watcher", {
		drawing = false,
		padding_left = 0,
		padding_right = 0,
	})

	watcher:subscribe({ "front_app_switched", "space_change", "system_woke", "forced" }, function(_)
		refresh()
	end)

	rift.subscribe({ "*" }, function(_)
		refresh()
	end)

	refresh()
end)
