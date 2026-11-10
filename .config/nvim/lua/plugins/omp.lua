return {
  {
    "omp.nvim",
    dir = vim.fn.expand("~/.omp/dev/omp.nvim"),
    event = "VeryLazy",
    config = function()
      require("omp").setup()
    end,
  },
}
