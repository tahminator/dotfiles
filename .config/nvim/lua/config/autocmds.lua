-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.opt.conceallevel = 0
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md", -- Apply only for Markdown files
  command = "RenderMarkdown disable",
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "leetcode.com_*.txt",
  command = "set filetype=java",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_augroup("sql_filetype", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.SQL",
  callback = function()
    vim.bo.filetype = "sql"
  end,
  group = "sql_filetype",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "Jenkinsfile",
  callback = function()
    vim.bo.filetype = "groovy"
  end,
})

-- I am not going to try to fix this BS anymore, I have had ENOUGH. Literally just removing this keymap so I don't have to
-- deal with these terrible defaults.
vim.schedule(function()
  local path = vim.fn.expand("~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/keymaps.lua")
  if vim.fn.filereadable(path) == 0 then
    return
  end

  local lines = vim.fn.readfile(path)

  local pattern =
    [[{ "<c%-k>", function%(%) return vim%.lsp%.buf%.signature_help%(%) end, mode = "i", desc = "Signature Help", has = "signatureHelp" },]]
  local filtered = vim.tbl_filter(function(line)
    return not line:match(pattern)
  end, lines)

  if #filtered < #lines then
    vim.fn.writefile(filtered, path)
    vim.notify("Deleted <C-k> keymap from LazyVim keymaps.lua", vim.log.levels.INFO)
  end
end)
