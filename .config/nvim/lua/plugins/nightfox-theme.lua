local block = false
if block then
  return {}
end

-- Monochrome carbonfox: white on black with greys for structure and a few
-- accents. Colors mirror the Ghostty theme (~/.config/ghostty/themes/mono);
-- keep the two in sync.
return {
  {
    "EdenEast/nightfox.nvim",
    opts = function()
      local C = require("nightfox.lib.color")
      local Shade = require("nightfox.lib.shade")
      local function shade(hex)
        return Shade.new(hex, 0.15, -0.15)
      end
      -- Faint hue: a Ghostty accent blended 55% into grey.
      local function tint(hex)
        return C(hex):blend(C("#a8a8a8"), 0.55):to_css()
      end

      require("nightfox").setup({
        palettes = {
          carbonfox = {
            -- Ghostty ANSI palette (also :terminal colors).
            black = shade("#252525"),
            red = shade("#dc5e94"),
            green = shade("#67bb6e"),
            yellow = shade("#fbe98a"),
            blue = shade("#5baef8"),
            magenta = shade("#ee85b4"),
            cyan = shade("#70d7d7"),
            white = shade("#dde0e5"),
            orange = shade("#ff8700"),
            pink = shade("#ee85b4"),

            comment = "#6c6c6c",

            bg0 = "#000000", -- status line and floats
            bg1 = "#000000", -- editor
            bg2 = "#121212", -- color column, folds
            bg3 = "#1c1c1c", -- cursor line
            bg4 = "#393939", -- borders, conceal

            fg0 = "#feffff",
            fg1 = "#feffff",
            fg2 = "#a8a8a8", -- status line, punctuation
            fg3 = "#6c6c6c", -- line numbers

            sel0 = "#252525", -- popup bg
            sel1 = "#393939", -- popup selection, search, visual (Ghostty selection)
          },
        },
        specs = {
          carbonfox = {
            syntax = {
              -- Grey ramp separates most roles. Keywords, functions, and
              -- types get a faint tint; strings and values keep full hues.
              bracket = "#767676",
              builtin0 = "#8a8a8a", -- self/this
              builtin1 = tint("#70d7d7"), -- builtin types: cyan
              builtin2 = "yellow", -- builtin constants
              comment = "comment",
              conditional = tint("#ee85b4"), -- magenta
              const = "yellow",
              field = "#b2b2b2",
              func = tint("#5baef8"), -- blue
              ident = "#d0d0d0",
              keyword = tint("#ee85b4"), -- magenta
              number = "yellow",
              operator = "#767676",
              preproc = "#8a8a8a", -- imports/includes
              regex = "yellow",
              statement = tint("#ee85b4"), -- magenta
              string = "green",
              type = tint("#70d7d7"), -- cyan
              variable = "#d0d0d0",
            },
            diag = {
              error = "red",
              warn = "yellow",
              info = "blue",
              hint = "cyan",
              ok = "green",
            },
            git = {
              changed = "yellow",
              conflict = "orange",
            },
          },
        },
        groups = {
          carbonfox = {
            Visual = { bg = "sel1" },
          },
        },
        options = {
          transparent = false,
          styles = {
            comments = "italic",
            keywords = "bold",
            conditionals = "bold",
            types = "italic",
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
