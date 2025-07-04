return {
  "AlexandrosAlexiou/kotlin.nvim",
  ft = { "kotlin" },
  config = function()
    require("kotlin").setup({
      -- Optional: Specify root markers for multi-module projects
      root_markers = {
        "gradlew",
        ".git",
        "mvnw",
        "settings.gradle",
      },
      -- Optional: Specify a custom Java path to run the server
      jre_path = "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home",
      -- Optional: Specify additional JVM arguments
      jvm_args = {
        "-Xmx4g",
      },
    })
  end,
}
