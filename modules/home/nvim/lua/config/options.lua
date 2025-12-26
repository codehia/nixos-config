-- =============================================================================
-- OPTIONS
-- =============================================================================

-- Set mapleader before any keymaps are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Make line numbers default with relative numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Disable mouse (matching reference config)
vim.o.mouse = ""
vim.o.showmode = false -- Don't show mode since we have statusline

-- Clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Window splits
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true

-- Indent and wrapping
vim.opt.cpoptions:append("I")
vim.o.expandtab = true
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,preview,noselect"

-- Enable true colors (matching reference config)
vim.o.termguicolors = true

-- Scroll offset
vim.o.scrolloff = 10

-- Hide command line when not in use
vim.o.cmdheight = 0

-- Folding configuration
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- List chars
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions
vim.opt.inccommand = "split"
