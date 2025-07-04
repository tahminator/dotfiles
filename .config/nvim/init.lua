-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.o.exrc = true

vim.filetype.add({
  pattern = {
    [".*%.gmrc"] = "json5",
  },
})
