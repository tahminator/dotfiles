local block = false
if block then
  return {}
end

return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      require("nightfox").setup({
        palettes = {
          carbonfox = {
            bg0 = "NONE", -- floating windows
            -- bg3 = "NONE", -- tabline + project name in neotree
          },
        },
        specs = {
          carbonfox = {
            syntax = {
              keyword = "magenta.dim",
              variable = "magenta",
              comment = "white.dim",
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
          colorblind = {
            enable = true,
            -- simulate_only = true,
            severity = {
              protan = 1,
              -- deutan = 1,
              -- tritan = 1,
            },
          },
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
