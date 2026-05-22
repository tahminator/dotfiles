os.execute(
	"[ ! -d $HOME/.local/share/sketchybar_lua/ ] && (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)"
)

-- ty @pyrorhythm
os.execute(
	"[ ! -d $HOME/.local/share/rift.lua/ ] && (git clone https://github.com/tahminator/rift.lua.git /tmp/rift.lua && cd /tmp/rift.lua/ && make install && rm -rf /tmp/rift.lua/)"
)

local user = os.getenv("USER")
package.cpath = package.cpath
	.. ";/Users/"
	.. user
	.. "/.local/share/sketchybar_lua/?.so"
	.. ";/Users/"
	.. user
	.. "/.local/share/rift.lua/?.so"

---@type SbarModule
SBAR = require("sketchybar")

SBAR.begin_config()

require("bar")
require("default")
require("items")

SBAR.end_config()
SBAR.event_loop()
