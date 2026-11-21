local block = true
if block then
  return {}
end

return {
  {
    "zenbones-theme/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.zenwritten = {
        darkness = "stark",
        transparent_background = true,
      }

      -- zenwritten doesn't style rainbow-delimiters, whose defaults are saturated hues.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "zenwritten",
        callback = function()
          for _, name in ipairs({ "Red", "Yellow", "Blue", "Orange", "Green", "Violet", "Cyan" }) do
            vim.api.nvim_set_hl(0, "RainbowDelimiter" .. name, { link = "Delimiter" })
          end
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "zenwritten",
    },
  },
}
