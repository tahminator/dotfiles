local block = true
if block then
  return {}
end

if vim.g.neovide then
  return {}
else
  return {
    "sphamba/smear-cursor.nvim",
    opts = {},
  }
end
