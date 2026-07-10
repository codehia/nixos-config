-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Move lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })

-- Centered scrolling
-- The centering (zz/zv) must run after mini.animate's scroll animation
-- finishes — appended directly it fires mid-animation and causes flicker
-- (:h MiniAnimate.config.scroll)
local function scroll_centered(key, center)
  return function()
    local count = vim.v.count > 0 and vim.v.count or ''
    local keys = vim.api.nvim_replace_termcodes(key, true, true, true)
    local ok, err = pcall(vim.cmd, 'normal! ' .. count .. keys)
    if not ok then
      vim.notify(err:gsub('^Vim%(%w+%):', ''), vim.log.levels.ERROR)
      return
    end
    if _G.MiniAnimate then
      MiniAnimate.execute_after('scroll', 'normal! ' .. center)
    else
      vim.cmd('normal! ' .. center)
    end
  end
end
vim.keymap.set('n', '<C-d>', scroll_centered('<C-d>', 'zz'), { desc = 'Scroll Down' })
vim.keymap.set('n', '<C-u>', scroll_centered('<C-u>', 'zz'), { desc = 'Scroll Up' })
vim.keymap.set('n', 'n', scroll_centered('n', 'zvzz'), { desc = 'Next Search Result' })
vim.keymap.set('n', 'N', scroll_centered('N', 'zvzz'), { desc = 'Previous Search Result' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Buffer navigation
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer', silent = true })
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer', silent = true })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete Buffer' })

-- Quickfix navigation
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Previous Quickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Next Quickfix' })

-- Clipboard keybindings
vim.keymap.set({ 'v', 'x', 'n' }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set(
  { 'n', 'v', 'x' },
  '<leader>Y',
  '"+yy',
  { noremap = true, silent = true, desc = 'Yank line to clipboard' }
)
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set(
  'i',
  '<C-p>',
  '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' }
)
vim.keymap.set(
  'x',
  '<leader>P',
  '"_dP',
  { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' }
)

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Arrow key warnings
vim.keymap.set({ 'n', 'i', 'v' }, '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Fold keymaps
local function close_all_folds()
  vim.api.nvim_exec2('%foldc!', { output = false })
end
local function open_all_folds()
  vim.api.nvim_exec2('%foldo!', { output = false })
end
vim.keymap.set('n', 'zR', open_all_folds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', close_all_folds, { desc = 'Close all folds' })

-- Save file
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- New file
vim.keymap.set('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New File' })

-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })
