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
vim.opt.undofile = false
-- vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
-- vim.opt.undofile = true

--
-- SEARCH
--
vim.opt.hlsearch = false
vim.opt.incsearch = true

--
-- CLIPBOARD
--
vim.opt.clipboard = ""

-- Over SSH, route the "+ / "* registers through OSC 52 so yanks/pastes land in
-- the LOCAL machine's clipboard (where the user sits), not this host's. nvim
-- >= 0.10 bundles an osc52 provider; the remote terminal emulator decodes the
-- escape sequence and writes to its own system clipboard. Local-only sessions
-- (no SSH) keep the built-in provider (pbcopy on macOS). tmux is left alone:
-- it owns its own clipboard passthrough, and forcing OSC52 there is untested.
local ssh =
  vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil or vim.env.SSH_CLIENT ~= nil
local tmux = vim.env.TMUX ~= nil
if ssh and not tmux then
  vim.g.clipboard = "osc52"
end

--
-- GLOBAL VARIABLES
--
vim.g.python_host_prog = "/usr/bin/python2"
vim.g.python3_host_prog = "/usr/bin/python3"

