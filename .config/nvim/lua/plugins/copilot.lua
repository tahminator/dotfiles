return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    opts = {},
    build = "make tiktoken", -- Only on MacOS or Linux
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = false,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<C-l>",
          accept_line = "<C-y>",
          next = false,
          refresh = "<C-e>",
          prev = false,
          dismiss = "<C-d>",
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        ghost_text = {
          enabled = true,
        },
      },
    },
  },
}
