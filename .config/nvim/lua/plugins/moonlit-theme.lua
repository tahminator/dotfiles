local block = false
if block then
  return {}
end

-- Palette sampled from ~/Pictures/wallpapers/moonlit-waterfall.gif (all blue/teal/foam),
-- lifted for legibility. Coral and sand are the only off-palette hues, reserved for
-- errors and warnings. Mirrored in ~/.config/ghostty/config and sketchybar/colors.lua.
local c = {
  night = "#183838",
  azure = "#5bb0cc",
  sky = "#80b8e8",
  ice = "#a8d4f0",
  teal = "#6fbfc0",
  seafoam = "#7cc4a4",
  periwinkle = "#9aa8f0",
  foam = "#e4f6f9",
  text = "#cfe6ea",
  dim = "#8fb0b6",
  comment = "#5f8a94",
  line = "#4f7680",
  coral = "#e8837c",
  sand = "#d8c88f",
}

return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = function()
      local Shade = require("nightfox.lib.shade")
      local function shade(hex)
        return Shade.new(hex, 0.15, -0.15)
      end

      require("nightfox").setup({
        options = {
          transparent = true,
          styles = {
            comments = "italic",
            keywords = "bold",
          },
        },
        palettes = {
          carbonfox = {
            black = shade(c.night),
            red = shade(c.coral),
            green = shade(c.seafoam),
            yellow = shade(c.sand),
            blue = shade(c.azure),
            magenta = shade(c.periwinkle),
            cyan = shade(c.teal),
            white = shade(c.text),
            orange = shade(c.periwinkle),
            pink = shade(c.periwinkle),
            comment = c.comment,
            bg0 = "NONE",
            bg1 = "#07141a",
            bg2 = "#0d1f24",
            bg3 = "#13292f",
            bg4 = "#2a4a52",
            fg0 = c.foam,
            fg1 = c.text,
            fg2 = c.dim,
            fg3 = c.line,
            sel0 = "#163640",
            sel1 = "#22505c",
          },
        },
        specs = {
          carbonfox = {
            syntax = {
              keyword = c.azure,
              conditional = c.azure,
              statement = c.azure,
              builtin0 = c.periwinkle,
              builtin1 = c.ice,
              builtin2 = c.periwinkle,
              const = c.periwinkle,
              number = c.periwinkle,
              func = c.sky,
              type = c.ice,
              string = c.seafoam,
              regex = c.seafoam,
              field = c.teal,
              ident = c.teal,
              preproc = c.teal,
              variable = c.text,
              operator = c.dim,
              bracket = c.dim,
              comment = c.comment,
            },
            diag = {
              error = c.coral,
              warn = c.sand,
              info = c.sky,
              hint = c.teal,
              ok = c.seafoam,
            },
            git = {
              add = c.seafoam,
              removed = c.coral,
              changed = c.sand,
            },
          },
        },
        groups = {
          carbonfox = {
            ["@type.qualifier"] = { fg = c.azure, style = "bold" },
            LineNr = { fg = c.line },
            CursorLineNr = { fg = c.foam, style = "bold" },
            CursorLine = { bg = "bg3" },
            Visual = { bg = "sel1" },
            WinSeparator = { fg = "bg4" },
            FloatBorder = { fg = "bg4" },
            Pmenu = { bg = "NONE" },
            PmenuSel = { bg = "sel1" },
            RainbowDelimiterRed = { fg = c.dim },
            RainbowDelimiterYellow = { fg = c.sky },
            RainbowDelimiterBlue = { fg = c.teal },
            RainbowDelimiterOrange = { fg = c.periwinkle },
            RainbowDelimiterGreen = { fg = c.ice },
            RainbowDelimiterViolet = { fg = c.seafoam },
            RainbowDelimiterCyan = { fg = c.azure },
          },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
}
