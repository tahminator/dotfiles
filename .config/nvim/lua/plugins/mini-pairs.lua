return {
  "echasnovski/mini.pairs",
  enabled = false,
  event = "VeryLazy",
  opts = {
    modes = { insert = true, command = false, terminal = false },

    -- Only insert matching pairs. Don't do smart behavior like overtyping or deletion
    mappings = {
      -- Only auto-close on open
      ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },

      -- Disable overtyping/closing logic
      [")"] = false,
      ["]"] = false,
      ["}"] = false,
      ['"'] = false,
      ["'"] = false,
      ["`"] = false,
    },
  },
  config = function(_, opts)
    LazyVim.mini.pairs(opts)
  end,
}
