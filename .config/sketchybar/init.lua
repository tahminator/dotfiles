os.execute(
	"[ ! -d $HOME/.local/share/sketchybar_lua/ ] && (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)"
)

package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

---@type SbarModule
SBAR = require("sketchybar")

SBAR.begin_config()

require("bar")
require("default")
require("items")

SBAR.end_config()
SBAR.event_loop()
