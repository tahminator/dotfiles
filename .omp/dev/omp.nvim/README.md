# omp.nvim

[![CI](https://github.com/rauls-kjarners/omp.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/rauls-kjarners/omp.nvim/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/omp.nvim.svg)](https://www.npmjs.com/package/omp.nvim)

A seamless integration bridge between Neovim and the Oh My Pi (OMP) coding agent.

This plugin tracks your cursor, active file, and visual selections inside Neovim and makes the current selection available to an active OMP terminal session — attached to the one message you're about to send, not injected as standing background context.

## Features

- **Active-File Widget:** Shows your current file and line in the OMP TUI, so you can see what Nvim thinks you're looking at.
- **Attach-on-Submit Selections:** Select a range in Neovim, switch to your OMP terminal, type your message, and the selected range is attached to that one message when you press Enter — not re-injected on every provider call for the rest of the turn.
- **One-Shot:** A selection is consumed by the message it's attached to; it won't resurface on a later, unrelated message.
- **Non-Blocking:** Uses `libuv` Unix sockets for zero impact on editor performance.

## Requirements

- Neovim >= 0.10.0
- Oh My Pi >= 18.2.1

## Installation & Setup

1. **Install the OMP extension (this fork, from the local path):**

   ```bash
   omp plugin uninstall omp.nvim   # drop the upstream npm install, if present
   omp plugin install ~/.omp/dev/omp.nvim
   ```

2. **Configure Neovim (LazyVim / lazy.nvim):**
   Point at the local checkout instead of the upstream GitHub repo (e.g., `~/.config/nvim/lua/plugins/omp.lua`):

   ```lua
   return {
     {
       "omp.nvim",
       dir = vim.fn.expand("~/.omp/dev/omp.nvim"),
       event = "VeryLazy",
       config = function()
         require("omp").setup()
       end,
     }
   }
   ```

3. **Add a Keymap:**
   If using `Snacks.terminal` (included in LazyVim), you can spawn OMP in a perfectly styled side-panel. Add this to `~/.config/nvim/lua/config/keymaps.lua`:

   ```lua
   vim.keymap.set("n", "<leader>ao", function()
     Snacks.terminal.toggle("omp", {
       win = {
         position = "right",
         width = 0.4
       }
     })
   end, { desc = "Toggle Oh My Pi" })
   ```

## Agent Behavior

This plugin tracks your cursor and selections passively (no extra setup required) but does **not** inject anything into the agent's context on its own. A range selected in Neovim is attached to your next message only when you submit it in the OMP TUI — once, as part of that message's own text, not as a recurring background note that follows every provider call inside the turn.

If no range is selected when you hit Enter, nothing is attached.

## Under the Hood

The project is split into two halves:

1. **The Neovim Plugin (`lua/omp`):** A lightweight Lua script that hooks into `BufEnter`, `CursorMoved`, and `CursorHold` events. It actively tracks your focused file and selection, and broadcasts them via non-blocking `libuv` pipes to matching OMP sockets in `$XDG_RUNTIME_DIR/omp-nvim-sockets` (Linux) or the system temp directory (macOS).
2. **The OMP Extension (`src/extension.ts`):** A native OMP extension that boots up alongside your terminal. It establishes a Unix domain socket and caches its location so Neovim can find it. It keeps the most recently broadcast selection in memory and, only when you submit a message yourself in the TUI, appends that selection to the literal text of the message you typed — then discards it.

Run `:checkhealth omp` inside Neovim to verify the integration is working correctly.

## Development

The OMP extension is written in TypeScript and runs natively on OMP's Bun engine without requiring compilation. Any changes to `src/extension.ts` will take effect the next time you boot or `/reload` an OMP instance. Changes to `lua/omp/init.lua` take effect when Neovim is restarted.
