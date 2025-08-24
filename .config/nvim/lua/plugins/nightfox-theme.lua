return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      require("nightfox").setup({
        palettes = {
          carbonfox = {
            bg0 = "NONE", -- floating windows
            bg3 = "NONE", -- tabline + project name in neotree
          },
        },
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
              bg = "bg2",
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
