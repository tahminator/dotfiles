return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      require("nightfox").setup({
        specs = {
          carbonfox = {
            syntax = {
              keyword = "magenta.dim",
              variable = "magenta",
            },
          },
        },
        groups = {
          carbonfox = {
            Visual = {
              bg = "bg4",
            },
          },
        },
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
