-- left
require("items.spaces")
require("items.front_app")
-- Both renderers subscribe before the backend publishes its initial state.
require("wm").start()

-- right
require("items.calendar")
require("items.wifi")
require("items.battery")
require("items.volume")
require("items.cpu")
require("items.memory")
