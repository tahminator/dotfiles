-- return {}

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      file_size = {
        enabled = false,
      },
      type = {
        enabled = false,
      },
      last_modified = {
        enabled = false,
      },
      created = {
        enabled = false,
      },
    },
    event_handlers = {
      {
        event = "before_git_status",
        handler = function(args)
          if vim.fs.normalize(args.git_root) ~= vim.fs.normalize(vim.fn.expand("~")) then
            return
          end
          -- Scanning ignored home directories can trigger macOS app-data prompts.
          for i, value in ipairs(args.status_args) do
            if value:match("^%-%-ignored=") then
              args.status_args[i] = "--ignored=no"
            end
          end
        end,
      },
      {
        event = "neo_tree_buffer_enter",
        handler = function(arg)
          vim.cmd([[
          setlocal relativenumber
        ]])
        end,
      },
    },
    use_popups_for_input = false,
    window = {
      fuzzy_finder_mappings = {
        ["<C-j>"] = "move_cursor_up",
        ["<C-k>"] = "move_cursor_down",
      },
    },
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
      },
    },
  },
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
