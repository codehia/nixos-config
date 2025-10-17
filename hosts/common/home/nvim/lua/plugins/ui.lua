-- =============================================================================
-- UI PLUGINS
-- =============================================================================

return {
  -- Colorscheme
  {
    'catppuccin-nvim',
    lazy = false,
    priority = 1000,
    after = function()
      require('catppuccin').setup({
        flavour = 'mocha',
        transparent_background = false,
        integrations = {
          blink_cmp = true,
          gitsigns = true,
          mini = true,
          treesitter = true,
          which_key = true,
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
        },
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  -- Better UI for vim.ui.select and vim.ui.input
  {
    'dressing-nvim',
    event = 'VeryLazy',
    after = function()
      require('dressing').setup()
    end,
  },

  -- Indent guides
  {
    'indent-blankline-nvim',
    event = 'BufReadPost',
    after = function()
      require('ibl').setup()
    end,
  },

  -- Status line and more
  {
    'mini-nvim',
    before = function()
      -- Mini.starter for start screen
      local starter = require('mini.starter')

      -- Custom header function
      local function get_header()
        local handle = io.popen('fortune | cowsay')
        if not handle then
          return 'Welcome to Neovim!'
        end
        local result = handle:read('*a')
        handle:close()
        return result or 'Welcome to Neovim!'
      end

      starter.setup({
        header = get_header(),
        items = {
          starter.sections.recent_files(5, false),
          starter.sections.recent_files(5, true),
          starter.sections.builtin_actions(),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.aligning('center', 'center'),
        },
      })

      -- Mini.statusline
      require('mini.statusline').setup({ use_icons = vim.g.have_nerd_font })

      -- Mini.pairs for auto-pairing brackets
      require('mini.pairs').setup()

      -- Mini.icons
      require('mini.icons').setup()

      -- Mini.ai for better text objects
      require('mini.ai').setup()

      -- Mini.surround for surround operations
      require('mini.surround').setup()
    end,
  },

  -- Notification manager
  {
    'snacks-nvim',
    before = function()
      require('snacks').setup({
        dashboard = { enabled = false },
        bigfile = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        lazygit = { enabled = true },
        git = { enabled = true },
      })

      -- Git keymaps
      local git = require('snacks.git')
      vim.keymap.set('n', '<leader>gb', git.blame_line, { desc = 'Git Blame Line' })
      vim.keymap.set('n', '<leader>gB', git.browse, { desc = 'Git Browse' })
      vim.keymap.set('n', '<leader>gf', git.browse, { desc = 'Git Browse File' })

      -- Lazygit
      local lazygit = require('snacks.lazygit')
      vim.keymap.set('n', '<leader>gg', function()
        lazygit.open()
      end, { desc = 'Lazygit' })
      vim.keymap.set('n', '<leader>gl', function()
        lazygit.log()
      end, { desc = 'Lazygit Log' })
      vim.keymap.set('n', '<leader>gL', function()
        lazygit.log_file()
      end, { desc = 'Lazygit Log (current file)' })
    end,
  },

  -- Which-key for keymap hints
  {
    'which-key-nvim',
    event = 'VeryLazy',
    after = function()
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add({
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>g', group = '[G]it' },
        { '<leader>f', group = '[F]ile' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>x', group = 'Diagnostics/Quickfi[x]' },
      })
    end,
  },
}
