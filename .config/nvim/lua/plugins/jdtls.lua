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
                path = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home",
              },
              {
                name = "JavaSE-11",
                path = "/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home",
              },
              {
                name = "JavaSE-21",
                path = "/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home",
              },
              {
                name = "JavaSE-25",
                path = "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home",
              },
            },
          },
          -- format = {
          --   settings = {
          --     url = vim.fn.expand("~/.config/nvim/java-formatter.xml"),
          --   },
          -- },
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
