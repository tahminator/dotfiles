-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_prettier_needs_config = false
vim.opt.spell = false
vim.g.opencode_opts.lsp.enabled = true

vim.lsp.enable("kotlin_lsp")

vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

vim.filetype.add({
  extension = {
    zsh = "sh",
    sh = "sh",
    zshrc = "sh",
    zprofile = "sh",
  },
  filename = {
    [".zshrc"] = "sh",
    [".zprofile"] = "sh",
  },
})
