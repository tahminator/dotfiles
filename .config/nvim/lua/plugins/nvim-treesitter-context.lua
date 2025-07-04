return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = function()
    require("treesitter-context").setup({
      trim_scope = "inner",
      max_lines = 5,
      mode = "topline",
    })
  end,
}
