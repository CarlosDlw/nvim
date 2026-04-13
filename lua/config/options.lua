-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.showcmd = false
opt.ruler = false
opt.laststatus = 3
opt.cmdheight = 1
opt.pumheight = 10
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Sem arquivos de backup/swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true

-- Busca
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Indentação
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- Split
opt.splitbelow = true
opt.splitright = true

-- Wrapping
opt.wrap = false

-- Clipboard do sistema
opt.clipboard = "unnamedplus"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Caracteres invisíveis
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Fillchars limpo
opt.fillchars = { eob = " " }
