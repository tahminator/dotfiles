return {
  { "justinsgithub/wezterm-types", lazy = true },
  {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "wezterm-types", modes = { "wezterm" } },
        },
      },
    },
  },
}
