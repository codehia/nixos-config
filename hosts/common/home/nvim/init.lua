-- =============================================================================
-- nixCats-nvim Configuration
-- =============================================================================

-- Set mapleader before any keymaps are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- =============================================================================
-- OPTIONS
-- =============================================================================

-- Make line numbers default with relative numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Disable mouse (matching reference config)
vim.o.mouse = ''
vim.o.showmode = false  -- Don't show mode since we have statusline

-- Clipboard integration
vim.opt.clipboard = 'unnamedplus'

-- Window splits
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true

-- Indent and wrapping
vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,preview,noselect'

-- Enhanced list characters (matching reference config)
vim.opt.list = true
vim.opt.listchars = {
  eol = '↲',     -- End of line
  tab = '▏·',    -- Tab character
  trail = '·',   -- Trailing spaces
  extends = '⟩', -- Character when text extends beyond window
  precedes = '⟨', -- Character when text precedes window
  nbsp = '␣',    -- Non-breaking space
}

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Set highlight on search
vim.opt.hlsearch = true

-- Scrolling and display
vim.opt.scrolloff = 10
vim.opt.laststatus = 3
vim.opt.splitkeep = 'screen'
vim.opt.smoothscroll = true

-- Fill characters for folds and diffs
vim.opt.fillchars = {
  foldopen = '▾',
  foldclose = '▸',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Disable netrw
vim.g.netrw_liststyle=0
vim.g.netrw_banner=0

-- Disable wrapping by default
vim.wo.wrap = false

-- Fold settings (matching reference config)
vim.opt.foldcolumn = '0'
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldnestmax = 3
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Keymaps for better default experience
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })

vim.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })
vim.keymap.set("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = 'delete buffer' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Enhanced Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Window navigation improvements
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Buffer navigation with Shift+hl
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer', silent = true })
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer', silent = true })

-- Clipboard keybindings
vim.keymap.set({"v", "x", "n"}, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({"n", "v", "x"}, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({'n', 'v', 'x'}, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+', { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Arrow key warnings (matching reference config)
vim.keymap.set({ 'n', 'i', 'v' }, '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set({ 'n', 'i', 'v' }, '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Fold keymaps (matching reference config)
local function close_all_folds()
  vim.api.nvim_exec2('%foldc!', { output = false })
end

local function open_all_folds()
  vim.api.nvim_exec2('%foldo!', { output = false })
end

vim.keymap.set('n', '<leader>zs', close_all_folds, { desc = '[s]hut all folds' })
vim.keymap.set('n', '<leader>zo', open_all_folds, { desc = '[o]pen all folds' })

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================

-- Disable auto comment on enter
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})



-- =============================================================================
-- PLUGINS
-- =============================================================================

-- Load catppuccin colorscheme with lze
require('lze').load {
  {
    "catppuccin-nvim",
    enabled = nixCats('general') or false,
    lazy = false, -- Load immediately since it's a colorscheme
    priority = 1000, -- High priority for colorscheme
    after = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = false, -- We use snacks explorer instead
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- Native LSP integration
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          -- Integration with other plugins we have
          lsp_trouble = false,
          telescope = false, -- We use snacks picker
          which_key = true,
        },
      })

      -- Set the colorscheme
      vim.cmd.colorscheme("catppuccin")
      
      -- Optional: Add keymaps for switching flavours
      vim.keymap.set('n', '<leader>cm', function()
        vim.cmd.colorscheme("catppuccin-mocha")
      end, { desc = 'Catppuccin Mocha' })
      
      vim.keymap.set('n', '<leader>cl', function()
        vim.cmd.colorscheme("catppuccin-latte")
      end, { desc = 'Catppuccin Latte' })
      
      vim.keymap.set('n', '<leader>cf', function()
        vim.cmd.colorscheme("catppuccin-frappe")
      end, { desc = 'Catppuccin Frappe' })
      
      vim.keymap.set('n', '<leader>cc', function()
        vim.cmd.colorscheme("catppuccin-macchiato")
      end, { desc = 'Catppuccin Macchiato' })
    end,
  }
}

-- Setup snacks.nvim
require("snacks").setup({
  explorer = {},
  picker = {},
  bigfile = { enabled = true },
  image = {},
  lazygit = { enabled = true },
  terminal = {},
  rename = {},
  notifier = {},
  indent = {},
  gitbrowse = {},
  scope = {},
  quickfile = { enabled = true },
  dashboard = {
    enabled = false,  -- Disabled in favor of mini.starter
  },
})
vim.keymap.set("n", "-", function() Snacks.explorer.open() end, { desc = 'Snacks Explorer' })
vim.keymap.set("n", "<c-\\>", function() Snacks.terminal.open() end, { desc = 'Snacks Terminal' })
vim.keymap.set("n", "<leader>_", function() Snacks.lazygit.open() end, { desc = 'Snacks LazyGit' })
vim.keymap.set('n', "<leader>sf", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
vim.keymap.set('n', "<leader><leader>s", function() Snacks.picker.buffers() end, { desc = "Search Buffers" })
-- find
vim.keymap.set('n', "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
vim.keymap.set('n', "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
-- Grep
vim.keymap.set('n', "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
vim.keymap.set('n', "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers" })
vim.keymap.set('n', "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Visual selection or ord" })
-- search
vim.keymap.set('n', "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines" })
vim.keymap.set('n', "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set('n', "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
vim.keymap.set('n', "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages" })
vim.keymap.set('n', "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps" })
vim.keymap.set('n', "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
vim.keymap.set('n', "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List" })
vim.keymap.set('n', "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks" })
vim.keymap.set('n', "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages" })
vim.keymap.set('n', "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
vim.keymap.set('n', "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume" })
vim.keymap.set('n', "<leader>su", function() Snacks.picker.undo() end, { desc = "Undo History" })
-- Git keymaps (matching reference config)
vim.keymap.set('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
vim.keymap.set('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
vim.keymap.set('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })
vim.keymap.set('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
vim.keymap.set('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
vim.keymap.set({'n', 'v'}, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse' })
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })
vim.keymap.set('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' })

-- Load other plugins with lze
require('lze').load {
  -- Basic plugins from reference config
  {
    "vim-sleuth",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
  },
  {
    "blink.cmp",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
    on_require = "blink",
    after = function (plugin)
      require("blink.cmp").setup({
        keymap = { preset = 'default' },
        appearance = {
          nerd_font_variant = 'mono'
        },
        signature = { enabled = true, },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
      })
    end,
  },
  {
    "nvim-treesitter",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
    load = function (name)
        vim.cmd.packadd(name)
        vim.cmd.packadd("nvim-treesitter-textobjects")
    end,
    after = function (plugin)
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true, },
        indent = { enable = false, },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }
    end,
  },
  {
    "mini.nvim",
    enabled = nixCats('general') or false,
    lazy = false,  -- Load immediately for starter
    priority = 1000,
    after = function (plugin)
      -- Better Around/Inside textobjects
      require('mini.ai').setup({ n_lines = 500 })
      
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      require('mini.surround').setup()
      
      -- Auto pairs
      require('mini.pairs').setup()
      
      -- Icons
      require('mini.icons').setup()
      
      -- Animate (optional)
      local has_animate, animate = pcall(require, 'mini.animate')
      if has_animate then
        animate.setup()
      end
      
      -- Starter (start page)
      local has_starter, starter = pcall(require, 'mini.starter')
      if has_starter then
        starter.setup({
          items = {
            starter.sections.recent_files(5, true, false),
            starter.sections.builtin_actions(),
          },
          content_hooks = {
            starter.gen_hook.adding_bullet(),
            starter.gen_hook.aligning('center', 'center'),
            starter.gen_hook.indexing('all', { 'Builtin actions' }),
            starter.gen_hook.padding(3, 2),
          },
          header = function()
            local handle = io.popen('fortune -s | cowsay', 'r')
            if handle then
              local output = handle:read('*all')
              handle:close()
              return output
            else
              -- Fallback if fortune/cowsay not available
              return table.concat({
                "██╗   ██╗██╗██╗  ██╗ ██████╗ █████╗ ████████╗███████╗",
                "██║   ██║██║╚██╗██╔╝██╔════╝██╔══██╗╚══██╔══╝██╔════╝",
                "██║   ██║██║ ╚███╔╝ ██║     ███████║   ██║   ███████╗",
                "██║   ██║██║ ██╔██╗ ██║     ██╔══██║   ██║   ╚════██║",
                "╚██████╔╝██║██╔╝ ██╗╚██████╗██║  ██║   ██║   ███████║",
                " ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝",
                "",
                "                  Powered by nixCats",
              }, "\n")
            end
          end,
          footer = '',
        })
      end
      
      -- Simple and easy statusline (replacing lualine)
      local has_statusline, statusline = pcall(require, 'mini.statusline')
      if has_statusline then
        statusline.setup({ use_icons = vim.g.have_nerd_font })
        
        -- Custom statusline active function
        statusline.active = function()
          local mode, mode_hl = statusline.section_mode({ trunc_width = 20000 })
          local git = statusline.section_git({ trunc_width = 40 })
          local filename = statusline.section_filename({ trunc_width = 20000 })
          local fileinfo = statusline.section_fileinfo({ trunc_width = 20000 })
          local location = statusline.section_location()
          
          return statusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl, strings = { location } },
          })
        end
        
        -- Custom location format
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end
    end,
  },
  {
    "vim-startuptime",
    enabled = nixCats('general') or false,
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  -- lualine.nvim disabled in favor of mini.statusline
  -- {
  --   "lualine.nvim",
  --   enabled = false,  -- Disabled in favor of mini.statusline
  -- },
  {
    "gitsigns.nvim",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
    after = function (plugin)
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "which-key.nvim",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
    after = function (plugin)
      require('which-key').setup({})
      require('which-key').add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>cc", group = "[c]opilot [c]hat" },
        { "<leader>cc_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>gt", group = "[g]it [t]oggle" },
        { "<leader>gt_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>f", group = "[f]ind" },
        { "<leader>f_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      }
    end,
  },
  {
    "nvim-lint",
    enabled = nixCats('general') or false,
    event = "FileType",
    after = function (plugin)
      require('lint').linters_by_ft = {
        go = nixCats('go') and { 'golangcilint' } or nil,
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  {
    "conform.nvim",
    enabled = nixCats('general') or false,
    keys = {
      { "<leader>FF", desc = "[F]ormat [F]ile" },
    },
    after = function (plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = nixCats('lua') and { "stylua" } or nil,
          go = nixCats('go') and { "gofmt", "golint" } or nil,
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },
  {
    "nvim-dap",
    enabled = nixCats('general') or false,
    keys = {
      { "<F5>", desc = "Debug: Start/Continue" },
      { "<F1>", desc = "Debug: Step Into" },
      { "<F2>", desc = "Debug: Step Over" },
      { "<F3>", desc = "Debug: Step Out" },
      { "<leader>b", desc = "Debug: Toggle Breakpoint" },
      { "<leader>B", desc = "Debug: Set Breakpoint" },
      { "<F7>", desc = "Debug: See last session result." },
    },
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-dap-ui")
      vim.cmd.packadd("nvim-dap-virtual-text")
    end,
    after = function (plugin)
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Basic debugging keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      }
    end,
  },
  {
    "nvim-dap-go",
    enabled = nixCats('go') or false,
    on_plugin = { "nvim-dap", },
    after = function(plugin)
      require("dap-go").setup()
    end,
  },
  {
    "lazydev.nvim",
    enabled = nixCats('lua') or false,
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  {
    "oil-nvim",
    enabled = nixCats('general') or false,
    keys = {
      { "<leader>-", desc = "Open parent directory" },
    },
    after = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
        },
        view_options = {
          show_hidden = true,
        },
      })

      vim.keymap.set("n", "<leader>-", "<CMD>oil<CR>", { desc = "Open parent directory with oil.nvim" })
    end,
  },
  {
    "indent-blankline.nvim",
    enabled = nixCats('general') or false,
    event = "DeferredUIEnter",
    after = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { 
          enabled = true,
          show_start = false, 
          show_end = false 
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })
    end,
  },
}

-- =============================================================================
-- LSP CONFIGURATION
-- =============================================================================

local function lsp_on_attach(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

  if nixCats('general') then
    nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
    nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
    nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
    nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
  end

  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Register LSP handler from lzextras
require('lze').register_handlers(require('lzextras').lsp)
require('lze').h.lsp.set_ft_fallback(function(name)
  return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes or {}
end)

require('lze').load {
  {
    "nvim-lspconfig",
    enabled = nixCats("general") or false,
    on_require = { "lspconfig" },
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = lsp_on_attach,
      })
    end,
  },
  {
    "lua_ls",
    enabled = nixCats('lua') or false,
    lsp = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixCats", "vim", },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    "gopls",
    enabled = nixCats("go") or false,
    lsp = {},
  },
  {
    "nixd",
    enabled = nixCats('nix') or false,
    lsp = {
      filetypes = { 'nix' },
      settings = {
        nixd = {
          nixpkgs = {
            expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
          },
          options = {
            nixos = {
              expr = nixCats.extra("nixdExtras.nixos_options")
            },
            ["home-manager"] = {
              expr = nixCats.extra("nixdExtras.home_manager_options")
            }
          },
          formatting = {
            command = { "alejandra" }
          },
          diagnostic = {
            suppress = {
              "sema-escaping-with"
            }
          }
        }
      },
    },
  },
  {
    "basedpyright",
    enabled = nixCats('python') or false,
    lsp = {
      cmd = { 'basedpyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
      },
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly",
          }
        }
      },
      on_attach = function(client, bufnr)
        lsp_on_attach(client, bufnr)
        
        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
          client:exec_cmd({
            command = 'basedpyright.organizeimports',
            arguments = { vim.uri_from_bufnr(bufnr) },
          })
        end, {
          desc = 'Organize Imports',
        })
      end,
    },
  },
  {
    "ts_ls",
    enabled = nixCats('typescript') or false,
    lsp = {
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    },
  },
  
  -- =============================================================================
  -- GITHUB COPILOT (Disabled by default - Press <leader>tc to enable)
  -- =============================================================================
  {
    "copilot-vim",
    enabled = nixCats('general') or false,
    event = "InsertEnter",
    load = function(name)
      vim.g.copilot_enabled = false
      vim.cmd.packadd(name)
      
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      vim.keymap.set('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion',
      })
      
      vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)', { desc = 'Next Copilot suggestion' })
      vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)', { desc = 'Previous Copilot suggestion' })
      vim.keymap.set('i', '<C-h>', '<Plug>(copilot-dismiss)', { desc = 'Dismiss Copilot suggestion' })
      
      vim.keymap.set('n', '<leader>tc', function()
        if vim.g.copilot_enabled then
          vim.cmd('Copilot disable')
          vim.g.copilot_enabled = false
          vim.notify('Copilot disabled', vim.log.levels.INFO)
        else
          vim.cmd('Copilot enable')
          vim.g.copilot_enabled = true
          vim.notify('Copilot enabled! Use <C-l> to accept suggestions', vim.log.levels.INFO)
        end
      end, { desc = '[T]oggle [C]opilot' })
    end,
  },
  {
    "CopilotChat-nvim",
    enabled = nixCats('general') or false,
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
    after = function()
      require('CopilotChat').setup({
        debug = false,
        show_help = 'yes',
        auto_insert_mode = false,
        window = {
          layout = 'vertical',
          width = 0.4,
        },
      })

      vim.keymap.set('n', '<leader>tC', '<cmd>CopilotChatToggle<cr>', { desc = '[T]oggle [C]opilot Chat' })
      vim.keymap.set('n', '<leader>ccq', function()
        local input = vim.fn.input('Quick Chat: ')
        if input ~= '' then
          require('CopilotChat').ask(input)
        end
      end, { desc = '[C]opilot [Q]uick chat' })
      
      vim.keymap.set('v', '<leader>cce', '<cmd>CopilotChatExplain<cr>', { desc = '[C]opilot [E]xplain' })
      vim.keymap.set('v', '<leader>ccr', '<cmd>CopilotChatReview<cr>', { desc = '[C]opilot [R]eview' })
      vim.keymap.set('v', '<leader>ccf', '<cmd>CopilotChatFix<cr>', { desc = '[C]opilot [F]ix' })
      vim.keymap.set('v', '<leader>cco', '<cmd>CopilotChatRefactor<cr>', { desc = '[C]opilot Refact[o]r' })
      vim.keymap.set('v', '<leader>cct', '<cmd>CopilotChatTests<cr>', { desc = '[C]opilot [T]ests' })
      vim.keymap.set('v', '<leader>ccd', '<cmd>CopilotChatDocs<cr>', { desc = '[C]opilot [D]ocs' })
    end,
  },
}
