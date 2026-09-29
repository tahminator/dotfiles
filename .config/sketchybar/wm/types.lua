---@alias AerospaceBinary 'aerospace'|'flightdeck'
---@alias WindowManagerName AerospaceBinary|'rift'

---@class WMWorkspace
---@field id string Stable backend ID (not a native macOS Space ID).
---@field label string
---@field focused boolean
---@field apps string[]
---@field display? integer

---@class WMState
---@field workspaces WMWorkspace[]
---@field front_app string Empty when no application is focused.

---@class WMBackend
---@field get_state fun(callback: fun(state: WMState?, err: string?)) Complete exactly once per request.
---@field watch fun(on_change: fun()) Register backend/native event sources once.
---@field focus_workspace fun(id: string)
---@field create_workspace? fun() Optional capability; used by right-click.

return {}
