return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    -- Disable formatting for SQL
    opts.formatters_by_ft.sql = nil

    -- opts.formatters.checkstyleme = {
    --   command = "checkstyle",
    --   args = function()
    --     local project_config = vim.fn.findfile("checkstyle.xml", vim.fn.getcwd() .. ";")
    --     local fallback_config = os.getenv("HOME") .. "/.config/nvim/checkstyle.xml"
    --
    --     -- Use project-specific checkstyle.xml if it exists, otherwise use the fallback
    --     local config_file = (project_config ~= "" and project_config) or fallback_config
    --
    --     return { "-c=" .. config_file, "$FILENAME" }
    --   end,
    --   condition = function(_, ctx)
    --     local filename = vim.fs.basename(ctx.filename)
    --
    --     -- Check if the file is a Java file or not "README.md"
    --     return filename:sub(-5) == ".java"
    --   end,
    -- }
    --
    -- opts.formatters_by_ft.java = { "checkstyleme" }
  end,
}
