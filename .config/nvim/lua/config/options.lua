-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--
-- BASIC DISPLAY
--
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.opt.termguicolors = true

vim.opt.nu = true
vim.opt.rnu = true
vim.opt.scrolloff = 5
vim.g.snacks_animate = false
vim.opt.wrap = false

vim.opt.updatetime = 50

--
-- TAB
--
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

--
-- BACKUP
--
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

--
-- SEARCH
--
vim.opt.hlsearch = false
vim.opt.incsearch = true

--
-- NO-UNDO
--
vim.opt.undofile = false
