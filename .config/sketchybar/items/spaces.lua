---@type SbarModule
local SBAR = SBAR

local colors = require("colors")
local icon_map = require("icon_map")

SBAR.add("event", "aerospace_workspace_change")

---@param workspace string
---@param is_focused boolean
local function update_workspace_appearance(workspace, is_focused)
	if not workspace or workspace == "" then
		return
	end

	local item_color = is_focused and colors.legacy.item or colors.legacy.accent

	SBAR.set("space." .. workspace, {
		background = { drawing = is_focused, color = colors.legacy.accent },
		label = { color = item_color },
		icon = { color = item_color },
	})
end

---@param monitor string
---@param workspace string
local function update_icons(monitor, workspace)
	SBAR.exec(
		string.format(
			"aerospace list-windows --monitor '%s' --workspace '%s' | awk -F '|' '{gsub(/^ *| *$/, \"\", $2); if (!seen[$2]++) print $2}' | sort",
			monitor,
			workspace
		),
		function(apps)
			if type(apps) == "string" then
				---@cast apps string
				local icon_strip = ""
				if apps and apps ~= "" then
					for app in apps:gmatch("[^\r\n]+") do
						icon_strip = icon_strip .. " " .. (icon_map[app] or ":default:")
					end
				else
					icon_strip = " —"
				end

				SBAR.animate("sin", 10, function()
					SBAR.set("space." .. workspace, { label = { string = icon_strip } })
				end)
			end
		end
	)
end

---@param monitor string
---@param focused_workspace string?
local function update_monitor_workspaces(monitor, focused_workspace)
	SBAR.exec("aerospace list-workspaces --monitor " .. monitor .. " --visible", function(workspaces)
		if type(workspaces) == "string" then
			---@cast workspaces string
			for workspace in workspaces:gmatch("[^\r\n]+") do
				SBAR.set("space." .. workspace, { display = tonumber(monitor) })
				update_icons(monitor, workspace)
			end
		end
	end)

	SBAR.exec("aerospace list-workspaces --monitor " .. monitor .. " --empty", function(empty_workspaces)
		if type(empty_workspaces) == "string" then
			---@cast empty_workspaces string
			for workspace in empty_workspaces:gmatch("[^\r\n]+") do
				if workspace ~= focused_workspace then
					SBAR.set("space." .. workspace, { display = 0 })
				end
			end
		end
	end)
end

---@param env SbarEnv
local function handle_workspace_update(env)
	if env.PREV_WORKSPACE and env.PREV_WORKSPACE ~= "" then
		update_workspace_appearance(env.PREV_WORKSPACE, false)
	end
	if env.FOCUSED_WORKSPACE and env.FOCUSED_WORKSPACE ~= "" then
		update_workspace_appearance(env.FOCUSED_WORKSPACE, true)
	end

	SBAR.exec("aerospace list-monitors | awk '{print $1}'", function(monitors_output)
		if type(monitors_output) == "string" then
			---@cast monitors_output string
			for monitor in monitors_output:gmatch("[^\r\n]+") do
				update_monitor_workspaces(monitor, env.FOCUSED_WORKSPACE)
			end
		end
	end)
end

local aerospace_dummy = SBAR.add("item", "aerospace_dummy", {
	position = "left",
	display = 0,
})

aerospace_dummy:subscribe("aerospace_workspace_change", handle_workspace_update)

SBAR.exec("aerospace list-monitors | awk '{print $1}'", function(monitors_output)
	if type(monitors_output) == "string" then
		---@cast monitors_output string
		for monitor in monitors_output:gmatch("[^\r\n]+") do
			SBAR.exec("aerospace list-workspaces --monitor " .. monitor, function(workspaces_output)
				if type(workspaces_output) == "string" then
					---@cast workspaces_output string
					for workspace in workspaces_output:gmatch("[^\r\n]+") do
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
							display = tonumber(monitor),
							click_script = "aerospace workspace " .. workspace,
						})

						update_icons(monitor, workspace)
					end

					SBAR.exec("aerospace list-workspaces --focused", function(focused)
						if type(focused) == "string" then
							---@cast focused string
							for workspace in focused:gmatch("[^\r\n]+") do
								update_workspace_appearance(workspace, true)
							end
						end
					end)

					update_monitor_workspaces(monitor, nil)
				end
			end)
		end
	end
end)

return aerospace_dummy
