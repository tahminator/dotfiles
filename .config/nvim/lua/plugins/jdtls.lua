return {
  {

    "mfussenegger/nvim-jdtls",
    -- NOTE: When it comes to protos, do this:
    -- 1. JdtUpdateConfig (99% of the time will pick up anything and be good to go)
    opts = {
      jdtls = {
        -- handlers = {
        --   ["$/progress"] = function() end,
        -- },
      },
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-17",
                path = "/opt/homebrew/opt/sdkman-cli/libexec/candidates/java/17.0.20-tem",
              },
              {
                name = "JavaSE-11",
                path = "/opt/homebrew/opt/sdkman-cli/libexec/candidates/java/11.0.32-tem",
              },
              {
                name = "JavaSE-21",
                path = "/opt/homebrew/opt/sdkman-cli/libexec/candidates/java/21.0.12-tem",
              },
              {
                name = "JavaSE-25",
                path = "/opt/homebrew/opt/sdkman-cli/libexec/candidates/java/25.0.4-tem",
              },
            },
          },
          format = {
            enabled = false,
            -- settings = {
            --   url = vim.fn.expand("~/.config/nvim/java-formatter.xml"),
            -- },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      -- Simple configuration to attach to remote java debug process
      -- Taken directly from https://github.com/mfussenegger/nvim-dap/wiki/Java
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
      },
    },
  },
}
