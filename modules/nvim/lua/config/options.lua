-- =============================================================================
-- OPTIONS
-- =============================================================================

-- Make line numbers default with relative numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Disable mouse
vim.o.mouse = ""
vim.o.showmode = false

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

-- Enhanced list characters
vim.opt.list = true
vim.opt.listchars = {
	eol = "↲",
	tab = "▏·",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
	nbsp = "␣",
}

-- Preview substitutions live
vim.opt.inccommand = "split"

-- Set highlight on search
vim.opt.hlsearch = true

-- Scrolling and display
vim.opt.scrolloff = 10
vim.opt.laststatus = 3
vim.opt.splitkeep = "screen"
vim.opt.smoothscroll = true

-- Fill characters for folds and diffs
vim.opt.fillchars = {
	foldopen = "▾",
	foldclose = "▸",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

-- True color support
vim.o.termguicolors = true

-- Disable netrw (oil replaces it)
vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0

-- Disable wrapping by default
vim.wo.wrap = false

-- Fold settings (foldmethod/foldexpr set in treesitter after hook to avoid
-- the race condition where expr folds are evaluated before treesitter loads)
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
