return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          layout = {
            auto_hide = { "input" },
          },
        },
      },
      win = {
        input = {
          keys = {
            ["<c-k>"] = { "list_down", mode = { "i", "n" } },
            ["<c-j>"] = { "list_up", mode = { "i", "n" } },
            ["k"] = "list_down",
            ["j"] = "list_up",
          },
        },
        list = {
          wo = { number = true, relativenumber = true, signcolumn = "no" },
          keys = {
            ["e"] = "toggle_maximize",
            ["<c-k>"] = "list_down",
            ["<c-j>"] = "list_up",
            ["k"] = "list_down",
            ["j"] = "list_up",
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.files({
          cwd = vim.fn.getcwd(),
        })
      end,
      desc = "Find Files (cwd)",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.grep({

          cwd = vim.fn.getcwd(),
        })
      end,
      desc = "Grep (cwd)",
    },
  },
}
