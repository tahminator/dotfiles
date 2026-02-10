local block = true
if block then
  return {}
end

return {
  {
    "rose-pine/neovim",
    name = "rose-pine-dawn",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-dawn",
    },
  },
}
