-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v", "o" }, "j", "k", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "k", "j", { noremap = true, silent = true })

vim.keymap.set({ "n", "v", "o" }, "<C-k>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "<C-j>", "<C-w>k", { noremap = true, silent = true })

vim.keymap.set(
  "n",
  "<leader>mt",
  "<cmd>RenderMarkdown toggle<CR>",
  { noremap = true, silent = true, desc = "Toggle Markdown beautify" }
)
vim.keymap.set(
  "n",
  "<leader>mp",
  "<cmd>MarkdownPreview<CR>",
  { noremap = true, silent = true, desc = "Launch Markdown preview" }
)

vim.keymap.set("n", "<leader>p", ":lua require('gitsigns').preview_hunk()<CR>")

vim.keymap.set("n", "c*", "*Ncgn", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ha", function()
  require("harpoon.mark").add_file()
end, { noremap = true, silent = true, desc = "Add file to Harpoon" })

vim.keymap.set("n", "<leader>hh", function()
  require("harpoon.ui").toggle_quick_menu()
end, { noremap = true, silent = true, desc = "Open Harpoon menu" })

for i = 1, 9 do
  vim.keymap.set("n", "<leader>h" .. i, function()
    require("harpoon.ui").nav_file(i)
  end, { noremap = true, silent = true, desc = "Open Harpoon file: index " .. i })
end

vim.keymap.set("n", "<Leader>r", function()
  local register = vim.fn.getcharstr()

  local count = vim.v.count

  if count == 0 then
    count = 1
  end
  for _ = 1, count do
    vim.cmd("normal @" .. register)
  end
end, { noremap = true, silent = true, desc = "Replay macro on given key" })

vim.keymap.set("n", "J", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "J", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<S-h>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-l>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "J", function()
  vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "Open diagnostics/errors on buffer" })

vim.keymap.set({ "n", "v" }, "dma", function()
  vim.cmd("delm! | delm A-Z0-9")
  vim.cmd("wshada!")
end, { desc = "Delete all marks" })

vim.keymap.set("n", "m", "'", { desc = "Jump to mark" })

vim.keymap.set("n", "<leader>m", "m", { desc = "Set mark" })

vim.keymap.set({ "n", "v" }, "d", '"_d', { noremap = true })
vim.keymap.set({ "n", "v" }, "c", '"_c', { noremap = true })

vim.keymap.set("n", "x", "d", { noremap = true })
vim.keymap.set("n", "xx", "dd", { noremap = true })

vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre",
})
vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word",
})
vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "Search current word",
})
vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
  desc = "Search on current file",
})

vim.keymap.set("n", "<Space>cc", function()
  -- Check if we're in diff mode
  if not vim.wo.diff then
    print("Not in diff mode")
    return
  end

  -- Get all diff buffers
  local diff_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_option(win, "diff") then
      table.insert(diff_buffers, buf)
    end
  end

  if #diff_buffers < 2 then
    print("Need at least 2 buffers in diff mode")
    return
  end

  -- Compare content of first two diff buffers
  local buf1_lines = vim.api.nvim_buf_get_lines(diff_buffers[1], 0, -1, false)
  local buf2_lines = vim.api.nvim_buf_get_lines(diff_buffers[2], 0, -1, false)

  local are_equal = #buf1_lines == #buf2_lines
  if are_equal then
    for i = 1, #buf1_lines do
      if buf1_lines[i] ~= buf2_lines[i] then
        are_equal = false
        break
      end
    end
  end

  if are_equal then
    print("Files are equivalent")
  else
    print("Files have differences")
  end
end, { desc = "Check if files in diff mode are equivalent" })

vim.keymap.set("n", "<leader>le", function()
  vim.ui.input(
    { prompt = "What is the Leetcode question you would like to convert to a directory name? " },
    function(input)
      if not input or input == "" then
        return
      end

      local number = input:match("^(%d+)%.?")
      if not number then
        vim.notify("Could not extract question number from input", vim.log.levels.ERROR)
        return
      end

      local title = input:match("^%d+%.?%s*(.+)$")
      if not title then
        vim.notify("Could not extract question title from input", vim.log.levels.ERROR)
        return
      end

      title = title:gsub("%s*$", "")

      local formatted_title = title:lower():gsub("[^%w%s]", ""):gsub("%s+", "_")

      local padded_number = string.format("%04d", tonumber(number))
      local result = "l" .. padded_number .. "_" .. formatted_title

      vim.fn.setreg("+", result)
      vim.notify("Copied to clipboard: " .. result, vim.log.levels.INFO)
    end
  )
end, { noremap = true, silent = true, desc = "Convert LeetCode question to directory name" })

vim.keymap.set("n", "<Up>", "<C-w>+")
vim.keymap.set("n", "<Down>", "<C-w>-")
vim.keymap.set("n", "<Left>", "<C-w><")
vim.keymap.set("n", "<Right>", "<C-w>>")

vim.keymap.set("n", "zf", "za", { desc = "Toggle fold under cursor" })

vim.keymap.set(
  "n",
  "<leader>kh",
  '<cmd>lua require("kubectl").toggle({ tab: boolean })<cr>',
  { noremap = true, silent = true }
)

vim.g.VM_custom_motions = {
  ["k"] = "j",
  ["j"] = "k",
}
