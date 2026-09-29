local config = require("wm.config")
---@type WMBackend
local backend

if config.backend == "rift" then
	backend = require("wm.rift").new()
else
	backend = require("wm.aerospace").new(config.backend, config.monitor)
end

return require("wm.controller").new(backend)
