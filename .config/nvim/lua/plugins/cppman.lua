return {
  "madskjeldgaard/cppman.nvim",
  dependencies = {
    { "MunifTanjim/nui.nvim" },
  },
  opts = {},
  setup = function()
    local cppman = require("cppman")
    cppman.setup()

    vim.keymap.set("n", "<leader>cm", function()
      cppman.open_cppman_for(vim.fn.expand("<cword>"))
    end)

    vim.keymap.set("n", "<leader>cc", function()
      cppman.input()
    end)
  end,
}
