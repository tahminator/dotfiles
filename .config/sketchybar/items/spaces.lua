---@type SbarModule
local SBAR = SBAR

local colors = require("colors")
local icon_map = require("icon_map")

SBAR.add("event", "aerospace_workspace_change")

local function exec_lines(command, on_line, on_done)
	SBAR.exec(command, function(out)
		if type(out) == "string" then
			for line in out:gmatch("[^\r\n]+") do
				on_line(line)
			end
		end
		if on_done then
			on_done()
		end
	end)
end

---@param workspace string
---@param is_focused boolean
local function set_focus_appearance(workspace, is_focused)
	local bg_color = is_focused and colors.bar.tertiary or colors.legacy.transparent
	SBAR.set("space." .. workspace, {
		background = { color = bg_color },
		icon = { color = colors.legacy.accent },
		label = { color = colors.legacy.accent },
	})
end

---@param workspace string
local function refresh_icons(workspace)
	local cmd = string.format("aerospace list-windows --monitor 1 --workspace '%s' --format '%%{app-name}'", workspace)
	SBAR.exec(cmd, function(out)
		if type(out) ~= "string" then
			return
		end

		local seen, apps = {}, {}
		for app in out:gmatch("[^\r\n]+") do
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
			SBAR.set("space." .. workspace, { label = { string = strip } })
		end)
	end)
end

---@param focused string?
local function refresh(focused)
	exec_lines("aerospace list-workspaces --monitor 1 --visible", function(workspace)
		SBAR.set("space." .. workspace, { display = 1 })
		refresh_icons(workspace)
	end)
	exec_lines("aerospace list-workspaces --monitor 1 --empty", function(workspace)
		if workspace ~= focused then
			SBAR.set("space." .. workspace, { display = 0 })
		end
	end)
end

---@param env SbarEnv
local function on_workspace_change(env)
	if env.PREV_WORKSPACE and env.PREV_WORKSPACE ~= "" then
		set_focus_appearance(env.PREV_WORKSPACE, false)
	end
	if env.FOCUSED_WORKSPACE and env.FOCUSED_WORKSPACE ~= "" then
		set_focus_appearance(env.FOCUSED_WORKSPACE, true)
	end
	refresh(env.FOCUSED_WORKSPACE)
end

---@param workspace string
local function create_space(workspace)
	SBAR.add("space", "space." .. workspace, {
		position = "left",
		space = workspace,
		icon = {
			string = workspace,
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
		display = 1,
		click_script = "aerospace workspace " .. workspace,
	})
end

exec_lines("aerospace list-workspaces --all", function(workspace)
	create_space(workspace)
	refresh_icons(workspace)
end, function()
	SBAR.exec("aerospace list-workspaces --focused", function(out)
		if type(out) ~= "string" then
			return
		end
		local focused = out:match("[^\r\n]+")
		if focused and focused ~= "" then
			set_focus_appearance(focused, true)
		end
		refresh(focused)
	end)
end)

local aerospace_dummy = SBAR.add("item", "aerospace_dummy", { position = "left", display = 0 })
aerospace_dummy:subscribe("aerospace_workspace_change", on_workspace_change)

return aerospace_dummy
