return {
  "carderne/pi-nvim",
  config = function(opts)
    require("pi-nvim").setup(opts)
  end,
  opts = {
    {
      socket_path = nil, -- auto-discover
      set_default_keymaps = true,
    },
  },
}
