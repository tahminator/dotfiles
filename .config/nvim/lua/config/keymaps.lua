-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v", "o" }, "j", "k", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "k", "j", { noremap = true, silent = true })

vim.keymap.set({ "n", "v", "o" }, "<C-k>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "o" }, "<C-j>", "<C-w>k", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { noremap = true, silent = true })

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
    vim.cmd("normal! @" .. register)
  end
end, { noremap = true, silent = true, desc = "Replay macro on given key" })

vim.keymap.set("n", "J", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "J", function()
  vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "Open diagnostics/errors on buffer" })

vim.keymap.set({ "n", "v" }, "dma", function()
  vim.cmd("delm! | delm A-Z0-9")
  vim.cmd("wshada!")
end)

vim.keymap.set("n", "m", "'", { desc = "Jump to mark" })

vim.keymap.set("n", "<leader>m", "m", { desc = "Set mark" })

vim.g.VM_custom_motions = {
  ["k"] = "j",
  ["j"] = "k",
}
