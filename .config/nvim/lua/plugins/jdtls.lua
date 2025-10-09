return {
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
}
