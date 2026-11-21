local block = true
if block then
  return {}
end

-- Pure greyscale, spaced by perceived lightness (CIE L* ~38-100) rather
-- than hex: pale greys blur together on a dark background, so the light end gets fewer,
-- wider steps. Mirrored in ~/.config/ghostty/config.
local g = {
  ui = "#2e2e2e",
  comment = "#666666",
  punct = "#595959",
  keyword = "#727272",
  string = "#8b8b8b",
  member = "#a6a6a6",
  text = "#a6a6a6",
  type = "#cccccc",
  call = "#ffffff",
  def = "#ffffff",
}

return {
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      tweak_color = {
        gray3 = "#2a2a2a",
        gray4 = g.ui,
        gray5 = g.comment,
        gray6 = g.keyword,
        gray7 = g.member,
      },
      tweak_syntax = {
        comment = g.comment,
        keyword = g.keyword,
        keyword_return = g.keyword,
        keyword_exception = g.keyword,
        builtin = g.member,
        string = g.string,
        type = g.type,
      },
      tweak_background = {
        normal = "none",
        menu = "none",
        popup = "none",
        telescope = "none",
      },
      tweak_highlight = {
        Comment = { italic = true },
        ["@comment"] = { italic = true },

        Delimiter = { fg = g.punct },
        Operator = { fg = g.punct },
        ["@operator"] = { fg = g.punct },
        ["@punctuation"] = { fg = g.punct },
        ["@punctuation.bracket"] = { fg = g.punct },
        ["@punctuation.delimiter"] = { fg = g.punct },
        ["@punctuation.special"] = { fg = g.punct },

        ["@keyword.modifier"] = { fg = g.keyword },
        ["@type.qualifier"] = { overwrite = true, fg = g.keyword },
        ["@attribute"] = { overwrite = true, fg = g.keyword, italic = true },
        ["@attribute.builtin"] = { overwrite = true, fg = g.keyword, italic = true },

        ["@string.escape"] = { fg = g.member },
        ["@string.special"] = { fg = g.member },
        ["@string.regexp"] = { fg = g.member },
        ["@lsp.type.regexp"] = { fg = g.member },
        ["@character.special"] = { overwrite = true, fg = g.member },
        ["@markup"] = { overwrite = true, fg = g.text },
        ["@markup.math"] = { fg = g.def },

        ["@module"] = { overwrite = true, fg = g.member },
        ["@variable.builtin"] = { fg = g.member },
        ["@function.builtin"] = { fg = g.member },
        ["@variable.member"] = { fg = g.member },
        ["@property"] = { fg = g.member },

        ["@variable"] = { fg = g.text },
        ["@variable.parameter"] = { fg = g.text, italic = true },
        ["@variable.parameter.builtin"] = { overwrite = true, fg = g.text, italic = true },

        Type = { fg = g.type },
        ["@type"] = { fg = g.type },
        ["@type.builtin"] = { fg = g.type },
        ["@type.definition"] = { fg = g.type },

        ["@function.call"] = { fg = g.call },
        ["@function.method.call"] = { fg = g.call },
        Function = { fg = g.def, bold = true },
        ["@function"] = { fg = g.def, bold = true },
        ["@function.method"] = { fg = g.def, bold = true },

        Constant = { fg = g.def },
        Number = { fg = g.def },
        Boolean = { fg = g.def },
        ["@constant"] = { fg = g.def },
        ["@constant.builtin"] = { fg = g.def },
        ["@number"] = { fg = g.def },
        ["@number.float"] = { fg = g.def },
        ["@boolean"] = { fg = g.def },

        LineNr = { fg = g.comment },
        LineNrAbove = { fg = g.comment },
        LineNrBelow = { fg = g.comment },
        CursorLineNr = { fg = g.def, bold = true },
        DiagnosticWarn = { fg = "#d2c08a" },
        DiagnosticVirtualTextWarn = { fg = "#d2c08a" },
        DiagnosticInfo = { fg = g.member },
        DiagnosticVirtualTextInfo = { fg = g.member },
        DiagnosticHint = { fg = g.member },
        DiagnosticVirtualTextHint = { fg = g.member },
        LspInlayHint = { fg = g.comment },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "lackluster",
    },
  },
}
