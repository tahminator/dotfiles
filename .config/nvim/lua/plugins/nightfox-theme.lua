return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      require("nightfox").setup({
        options = {
          transparent = true,
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "dayfox",
      colorscheme = "carbonfox",
      transparent = true,
    },
  },
}

-- available colorschemes:
-- carbonfox
-- terafox
-- nordfox
-- duskfox
-- dawnfox
-- dayfox
-- nightfox
