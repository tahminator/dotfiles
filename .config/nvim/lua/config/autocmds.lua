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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = ".env.*",
  command = "set filetype=sh",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = ".gotpl.*",
  command = "set filetype=go",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = ".gotpl.*",
  command = "set filetype=go",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = ".env*",
  command = "set filetype=sh",
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
  local path = vim.fn.expand("~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/init.lua")
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 0
  end,
})
vim.api.nvim_create_user_command("JdtClean", function()
  vim.fn.delete(vim.fn.expand("~/.cache/nvim/jdtls"), "rf")
  vim.fn.delete(vim.fn.expand("~/.cache/jdtls"), "rf")
  vim.fn.delete(vim.fn.expand("~/.local/share/jdtls"), "rf")
  print("Deleted cache!")
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.defer_fn(function()
        vim.cmd("wincmd l")
        require("snacks").dashboard.open({ win = 0 })
        vim.cmd("wincmd h")
      end, 300)
    end
  end,
})

-- auto start claude LSP integration
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local dir = tostring(vim.fn.argv(0))

    -- resolve to an absolute path (argv(0) may be ".", "", or relative)
    local abs = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
    local home = vim.fn.expand("~")

    if vim.fn.isdirectory(dir) == 1 and abs ~= home then
      vim.defer_fn(function()
        local keys = vim.api.nvim_replace_termcodes("<leader>ac", true, false, true)
        vim.api.nvim_feedkeys(keys, "m", true)
      end, 1000)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.{ts,js,tsx,jsx}",
  command = "LspOxlintFixAll",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- Fold `mod test` / `mod tests` blocks the first time a Rust buffer is shown.
-- LazyVim swaps foldexpr from treesitter to LSP once rust-analyzer attaches, which
-- resets fold state, so wait for the LSP foldexpr (or give up waiting after 3s).
local rust_test_mod_query
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("rust_fold_tests", { clear = true }),
  pattern = "*.rs",
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].rust_tests_folded then
      return
    end
    vim.b[buf].rust_tests_folded = true

    local ok, parser = pcall(vim.treesitter.get_parser, buf, "rust")
    if not ok or not parser then
      return
    end
    rust_test_mod_query = rust_test_mod_query
      or vim.treesitter.query.parse(
        "rust",
        [[(mod_item name: (identifier) @name body: (declaration_list) (#any-of? @name "test" "tests")) @mod]]
      )

    local mods = {}
    for _, match in rust_test_mod_query:iter_matches(parser:parse()[1]:root(), buf) do
      local m = {}
      for id, nodes in pairs(match) do
        m[rust_test_mod_query.captures[id]] = nodes[1]
      end
      local srow, _, erow = m.mod:range()
      mods[#mods + 1] = { line = m.name:start() + 1, first = srow + 1, last = erow + 1 }
    end
    if #mods == 0 then
      return
    end

    local win = vim.api.nvim_get_current_win()
    local deadline = vim.uv.now() + 3000
    local function try()
      if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end
      vim.api.nvim_win_call(win, function()
        local lsp_folds = vim.wo.foldexpr:find("lsp") ~= nil
        local folds_ready = vim.iter(mods):all(function(mod)
          return vim.fn.foldlevel(mod.line) > 0
        end)
        if not (lsp_folds and folds_ready) and vim.uv.now() < deadline then
          return vim.defer_fn(try, 100)
        end
        local cursor = vim.fn.line(".")
        for _, mod in ipairs(mods) do
          -- don't hide the cursor if we jumped straight into a test
          if vim.fn.foldlevel(mod.line) > 0 and (cursor < mod.first or cursor > mod.last) then
            vim.cmd(mod.line .. "foldclose")
          end
        end
      end)
    end
    try()
  end,
})
