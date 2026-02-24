-- /lua/plugins/nvim-lspconfig.lua

local enabledFlag = vim.g.started_by_firenvim ~= true

return {
  {
    "davidosomething/format-ts-errors.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "<c-k>", false },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/refs/heads/master/v1.9.9/all.json"] = "{release}.{yml,yaml}*",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/refs/heads/master/v1.9.9/deployment.json"] = "{deployment}.{yml,yaml}*",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/refs/heads/master/v1.9.9/secret.json"] = "{secret,secrets}.{yml,yaml}*",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/refs/heads/master/v1.9.9/service.json"] = "{service}.{yml,yaml}*",
                ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
                ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
                ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
                ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
                ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
                ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
              },
            },
          },
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
