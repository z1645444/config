-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map("n", "<leader>Y", '"+y', { noremap = true, silent = true })
map("v", "<leader>Y", '"+y', { noremap = true, silent = true })
map("n", "<leader>P", '"+p', { noremap = true, silent = true })
map("v", "<leader>P", '"+p', { noremap = true, silent = true })

-- disabled move line
vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
vim.keymap.del("v", "<A-j>")
vim.keymap.del("v", "<A-k>")

-- copy filename
vim.keymap.set("n", "<leader>fyn", function()
  local filename = vim.fn.expand("%:t")
  vim.fn.setreg("+", filename)
  vim.notify("Copied filename: " .. filename)
end, { desc = "Copy Filename" })

-- copy relative path
vim.keymap.set("n", "<leader>fyr", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify("Copied relative path: " .. path)
end, { desc = "Copy Relative Path" })

-- absolute path
vim.keymap.set("n", "<leader>fya", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied absolute path: " .. path)
end, { desc = "Copy Absolute Path" })
