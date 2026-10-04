# 🪄 SketchyBar

<div align="center">

<br/>
<a href="https://github.com/FelixKratz/SketchyBar"><img src="https://img.shields.io/badge/SketchyBar-macOS-C13584?style=for-the-badge&logoColor=white" alt="macOS Status Bar"/></a>

_A customizable replacement for the macOS status bar_

</div>

## 📸 Preview

![Tmux](../docs/images/sketchybar.png)

## 🚀 Installation

**Install SketchyBar**

```bash
brew install felixkratz/formulae/sketchybar
```

**Install jq**

```bash
brew install jq
```

## 🔤 Font Setup

**Install ProggyClean Nerd Font** (same font as Ghostty; set in `font.lua`)

```bash
brew install --cask font-proggy-clean-tt-nerd-font
```

**Install SketchyBar App Font**

```bash
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.40/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
```

**Add icon_map.sh file**

```bash
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.40/icon_map.sh -o $HOME/.config/sketchybar/icon_map.sh
```

## ⚙️ Configuration

### Window manager backend

Select the backend in `wm/config.lua`:

```lua
---@type WindowManagerName
local backend = "aerospace" -- "aerospace", "flightdeck", or "rift"

return {
    backend = backend,
    monitor = 1, -- AeroSpace/Flightdeck monitor and SketchyBar display
}
```

AeroSpace and Flightdeck use the same adapter with a typed, runtime-validated
binary name. Rift uses `riftapi`; its native bridge is installed/loaded only when
Rift is selected. Restart/reload SketchyBar after changing backends.

Both `items/spaces.lua` and `items/front_app.lua` render the same normalized state.
Empty, inactive workspaces are hidden; focused or occupied workspaces are shown.
Left-click switches workspace. Right-click creates a workspace on Rift; on the
AeroSpace-compatible backend it switches workspace normally. Rift retains its
existing labels, with numeric fallback for additional workspaces.

Existing `aerospace_workspace_change` and `front_app_changed` hooks still work.
Flightdeck accepts those same hooks plus `flightdeck_workspace_change`. Native
SketchyBar events and a five-second fallback refresh cover missed window changes;
Rift also subscribes to its API events. No window-manager config changes are needed
for polling, but workspace-change hooks provide immediate updates.

### Interface and implementation

`wm/types.lua` defines the LuaLS structural interface `WMBackend`:

- `get_state(callback)` returns a `WMState` (workspaces and focused app), or an error.
  Invoke the callback exactly once; it may run synchronously or asynchronously.
- `watch(on_change)` registers invalidation events once.
- `focus_workspace(id)` focuses a backend workspace ID.
- Optional `create_workspace()` advertises workspace-creation support.

LuaLS checks the annotations in the editor; `wm/controller.lua` also validates
required methods at runtime. The controller shares one subscription across both
items, serializes refreshes, discards invalidated snapshots, and retains the last
good state when the window manager is unavailable. App names retain their spaces.

The configuration files are organized as follows:

- `sketchybarrc` / `init.lua` - Entry points
- `colors.lua` - Color definitions (mirrors the Ghostty palette)
- `font.lua` - Fonts and character-cell spacing
- `sparkline.lua` - Text meter used by the CPU and memory items
- `items/` - Backend-independent UI components
- `wm/config.lua` - Backend selection
- `wm/aerospace.lua` / `wm/rift.lua` - The two backend implementations
- `wm/controller.lua` - Shared state and refresh lifecycle
- `riftapi/` - Existing Rift API bridge

Run mocked adapter/controller/UI tests without a running bar:

```bash
cd ~/.config/sketchybar
lua tests/wm_test.lua
```

## 🔗 Useful Links

- [Official SketchyBar Repository](https://github.com/FelixKratz/SketchyBar)
- [SketchyBar Wiki](https://github.com/FelixKratz/SketchyBar/wiki)
- [SketchyBar Examples](https://github.com/FelixKratz/SketchyBar/discussions/47)
