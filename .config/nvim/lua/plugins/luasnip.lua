return {
  "L3MON4D3/LuaSnip",
  optional = true,
  opts = function(_, opts)
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("go", {
      s("iferr", {
        t({ "if err != nil {", "\t" }),
        i(1, "return err"),
        t({ "", "}" }),
      }),
    })
  end,
}
