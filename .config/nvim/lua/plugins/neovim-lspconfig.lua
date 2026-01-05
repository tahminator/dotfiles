-- /lua/plugins/nvim-lspconfig.lua

local enabledFlag = vim.g.started_by_firenvim ~= true

return {
  {
    "davidosomething/format-ts-errors.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      if vim.g.started_by_firenvim == true then
        keys[#keys + 1] = { "K", "" }
      end
      keys[#keys + 1] = { "<c-k>", false }
      -- local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
      -- if client ~= nil and client.name == "Firenvim" then
      -- end
      -- nvim-lspconfig don't handle this logic anymore. it's spread out between blink.cmp, noice/snacks, etc.
      -- return {
      --   defaults = {
      --     mappings = {
      --       i = {
      --         ["<C-j>"] = "move_selection_previous", -- up
      --         ["<C-k>"] = "move_selection_next", -- down
      --       },
      --       n = {
      --         ["<C-j>"] = "move_selection_previous",
      --         ["<C-k>"] = "move_selection_next",
      --       },
      --     },
      --   },
      -- }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = { enabled = false },
        vtsls = { enabled = false },
        tsgo = {
          cmd = { "tsgo", "--lsp", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_markers = {
            "tsconfig.json",
            "jsconfig.json",
            "package.json",
            ".git",
            "tsconfig.base.json",
          },
          enabled = true,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      diagnostics = {
        enable = enabledFlag,
        underline = enabledFlag,
        update_in_insert = enabledFlag,
        virtual_text = enabledFlag,
        severity_sort = enabledFlag,
        signs = enabledFlag,
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
      },
      servers = {
        marksman = {
          mason = false,
        },
        markdownlint = {
          mason = false,
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
        jdtls = {},
        tsserver = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
              if result.diagnostics == nil then
                return
              end

              -- ignore some tsserver diagnostics
              local idx = 1
              while idx <= #result.diagnostics do
                local entry = result.diagnostics[idx]

                local formatter = require("format-ts-errors")[entry.code]
                entry.message = formatter and formatter(entry.message) or entry.message

                -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
                if entry.code == 80001 then
                  -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
                  table.remove(result.diagnostics, idx)
                else
                  idx = idx + 1
                end
              end

              vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
            end,
          },
        },
        vtsls = {
          settings = {
            typescript = {
              preferences = {
                includeCompletionsForModuleExports = true,
                includeCompletionsForImportStatements = true,
                importModuleSpecifier = "non-relative",
              },
            },
          },
        },
      },
    },
  },
}
