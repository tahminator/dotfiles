local block = true
if block then
  return {}
end

return {
  {
    "olivercederborg/poimandres.nvim",
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "poimandres",
    },
  },
}
