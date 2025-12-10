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
