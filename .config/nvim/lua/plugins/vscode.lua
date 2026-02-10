local block = true
if block then
  return {}
end

return {
  "shadowy-pycoder/arctic.nvim",
  dependencies = { "rktjmp/lush.nvim" },
  name = "arctic",
  branch = "v2",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme arctic")
  end,
}
