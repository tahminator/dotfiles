local block = true
if block then
  return {}
end

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
