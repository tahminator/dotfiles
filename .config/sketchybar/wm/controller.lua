local M = {}

---@param backend WMBackend
function M.new(backend)
	for _, method in ipairs({ "get_state", "watch", "focus_workspace" }) do
		assert(type(backend[method]) == "function", "WMBackend missing method: " .. method)
	end
	assert(backend.create_workspace == nil or type(backend.create_workspace) == "function", "Invalid create_workspace capability")

	local listeners = {}
	local started, busy, dirty = false, false, false
	---@type WMState?
	local current
	local controller = {}

	function controller.refresh()
		if busy then
			dirty = true
			return
		end
		busy = true
		backend.get_state(function(state, err)
			busy = false
			if dirty then
				-- Discard a snapshot invalidated by an event while it was loading.
				dirty = false
				controller.refresh()
				return
			end
			if not state then
				print("[wm] " .. tostring(err))
				return -- Keep the last successful state during WM restarts.
			end
			current = state
			for _, listener in ipairs(listeners) do
				listener(state)
			end
		end)
	end

	---@param listener fun(state: WMState)
	function controller.subscribe(listener)
		listeners[#listeners + 1] = listener
		if current then
			listener(current)
		end
	end

	function controller.start()
		if started then
			return
		end
		started = true
		backend.watch(controller.refresh)
		controller.refresh()
	end

	---@param id string
	---@param button? string
	function controller.activate_workspace(id, button)
		if button == "right" and backend.create_workspace then
			backend.create_workspace()
		else
			backend.focus_workspace(id)
		end
		controller.refresh()
	end

	return controller
end

return M
