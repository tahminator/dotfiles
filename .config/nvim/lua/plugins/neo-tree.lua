return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- opts.window.position = "right"
    opts.event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function(arg)
          vim.cmd([[
          setlocal relativenumber
        ]])
        end,
      },
    }
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
    opts.filesystem.filtered_items.hide_dotfiles = false
  end,
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (Root Dir)", remap = true },
  },
}
