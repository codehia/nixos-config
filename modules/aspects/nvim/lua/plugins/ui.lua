-- =============================================================================
-- UI PLUGINS
-- =============================================================================

return {
  -- ---------------------------------------------------------------------------
  -- Colorscheme — tokyonight (active) / catppuccin (commented out)
  -- ---------------------------------------------------------------------------
  {
    'tokyonight.nvim',
    lazy = false,
    priority = 1000,
    after = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = false,
        terminal_colors = false,
        dim_inactive = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = 'dark',
          floats = 'dark',
        },
        -- plugins.all defaults to true when lazy.nvim is not loaded (we use lze).
        -- All 80+ integrations (navic, telescope, blink-cmp, treesitter, gitsigns,
        -- which-key, noice, trouble, indent-blankline, mini, etc.) auto-enabled.
        on_highlights = function(hl, c)
          hl.GitSignsAdd = { fg = c.git.add, bold = true }
          hl.GitSignsChange = { fg = c.git.change, bold = true }
          hl.GitSignsDelete = { fg = c.git.delete, bold = true }
          hl.GitSignsTopdelete = { fg = c.git.delete, bold = true }
          hl.GitSignsChangedelete = { fg = c.git.change, bold = true }
        end,
      })
      vim.cmd.colorscheme('tokyonight')
    end,
  },
  -- {
  --   'catppuccin-nvim',
  --   lazy = false,
  --   priority = 1000,
  --   after = function()
  --     require('catppuccin').setup({
  --       flavour = 'mocha',
  --       transparent_background = false,
  --       show_end_of_buffer = false,
  --       term_colors = false,
  --       dim_inactive = { enabled = false },
  --       styles = {
  --         comments = { 'italic' },
  --         conditionals = { 'italic' },
  --       },
  --       integrations = {
  --         blink_cmp = true,
  --         gitsigns = true,
  --         mini = { enabled = true },
  --         treesitter = true,
  --         which_key = true,
  --         native_lsp = {
  --           enabled = true,
  --           virtual_text = {
  --             errors = { 'italic' },
  --             hints = { 'italic' },
  --             warnings = { 'italic' },
  --             information = { 'italic' },
  --           },
  --           underlines = {
  --             errors = { 'underline' },
  --             hints = { 'underline' },
  --             warnings = { 'underline' },
  --             information = { 'underline' },
  --           },
  --           inlay_hints = { background = true },
  --         },
  --         telescope = { enabled = true },
  --         lsp_trouble = true,
  --         indent_blankline = { enabled = true },
  --         navic = { enabled = true },
  --         noice = true,
  --       },
  --     })
  --     vim.cmd.colorscheme('catppuccin')
  --   end,
  -- },
  -- ---------------------------------------------------------------------------
  -- Snacks — notifier, lazygit, bigfile (NOT picker/explorer)
  -- ---------------------------------------------------------------------------
  {
    'snacks.nvim',
    lazy = false,
    before = function()
      require('snacks').setup({
        dashboard = { enabled = false },
        bigfile = { enabled = true },
        notifier = { enabled = true, timeout = 3000 },
        quickfile = { enabled = true },
        lazygit = { enabled = true },
        git = { enabled = true },
      })

      vim.keymap.set('n', '<leader>gg', function()
        Snacks.lazygit()
      end, { desc = 'Lazygit' })
      vim.keymap.set('n', '<leader>gl', function()
        Snacks.lazygit.log()
      end, { desc = 'Lazygit Log' })
      vim.keymap.set({ 'n', 'v' }, '<leader>gB', function()
        Snacks.gitbrowse()
      end, { desc = 'Git Browse' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Which-Key — keymap hints
  -- ---------------------------------------------------------------------------
  {
    'which-key.nvim',
    event = 'DeferredUIEnter',
    after = function()
      require('which-key').setup()
      require('which-key').add({
        { '<leader>a', group = '[A]I' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument / Debug' },
        { '<leader>f', group = '[F]ile' },
        { '<leader>g', group = '[G]it' },
        { '<leader>gt', group = '[G]it [T]oggle' },
        { '<leader>h', group = 'Git [H]unk' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>x', group = 'Diagnostics/Quickfi[x]' },
        { '<leader>m', group = '[M]arkview' },
        { '<leader>o', group = '[O]bsidian' },
        { '<leader>z', group = '[Z]en' },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Dressing — better vim.ui.select and vim.ui.input
  -- ---------------------------------------------------------------------------
  {
    'dressing.nvim',
    lazy = false,
    after = function()
      require('dressing').setup({
        input = {
          border = 'rounded',
        },
        select = {
          builtin = {
            border = 'rounded',
          },
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Noice — cmdline, messages, popupmenu UI
  -- ---------------------------------------------------------------------------
  {
    'noice.nvim',
    lazy = false,
    after = function()
      require('noice').setup({
        cmdline = { enabled = true },
        messages = { enabled = true },
        popupmenu = { enabled = true },
        notify = { enabled = false }, -- snacks.notifier handles vim.notify
        lsp = {
          hover = { enabled = false }, -- lspsaga handles hover
          signature = { enabled = false }, -- blink-cmp handles signature
          progress = { enabled = true },
          message = { enabled = true },
          documentation = { enabled = true },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Lspkind — vscode-style completion icons (dep of blink-cmp)
  -- ---------------------------------------------------------------------------
  {
    'lspkind.nvim',
    dep_of = { 'blink.cmp' },
    lazy = true,
  },

  -- ---------------------------------------------------------------------------
  -- Indent-blankline — indent guides
  -- ---------------------------------------------------------------------------
  {
    'indent-blankline.nvim',
    event = 'BufReadPost',
    after = function()
      require('ibl').setup({
        indent = { char = '│', tab_char = '│' },
        scope = { enabled = true, show_start = false, show_end = false },
        exclude = {
          filetypes = {
            'help',
            'dashboard',
            'Trouble',
            'trouble',
            'notify',
            'starter',
          },
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Nvim-navic — breadcrumbs in winbar
  -- ---------------------------------------------------------------------------
  {
    'nvim-navic',
    event = 'DeferredUIEnter',
    after = function()
      require('nvim-navic').setup({
        icons = {
          File = '󰈙 ',
          Module = ' ',
          Namespace = '󰌗 ',
          Package = ' ',
          Class = '󰌗 ',
          Method = '󰆧 ',
          Property = ' ',
          Field = ' ',
          Constructor = ' ',
          Enum = '󰕘 ',
          Interface = '󰕘 ',
          Function = '󰊕 ',
          Variable = '󰆧 ',
          Constant = '󰏿 ',
          String = ' ',
          Number = '󰎠 ',
          Boolean = '◩ ',
          Array = '󰅪 ',
          Object = '󰅩 ',
          Key = '󰌋 ',
          Null = '󰟢 ',
          EnumMember = ' ',
          Struct = '󰌗 ',
          Event = ' ',
          Operator = '󰆕 ',
          TypeParameter = '󰊄 ',
        },
        lsp = { auto_attach = false },
        highlight = true,
        separator = ' > ',
        depth_limit = 0,
        depth_limit_indicator = '..',
        safe_output = true,
        click = true,
      })
      vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Vim-startuptime — :StartupTime profiler
  -- ---------------------------------------------------------------------------
  {
    'vim-startuptime',
    cmd = { 'StartupTime' },
    before = function()
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 0
    end,
  },
  -- ---------------------------------------------------------------------------
  -- Markview — Markdown/LaTeX/Typst previewer (must not be lazy-loaded)
  -- ---------------------------------------------------------------------------
  {
    'markview.nvim',
    lazy = false,
    after = function()
      require('markview').setup({
        preview = {
          icon_provider = 'devicons',
          callbacks = {
            on_attach = function(buffer, wins)
              -- Auto-open splitview for markdown buffers
              require('markview.actions').splitOpen(buffer)
              for _, win in ipairs(wins) do
                vim.wo[win].conceallevel = 3
              end
            end,
          },
        },
      })

      vim.keymap.set('n', '<leader>mt', '<cmd>Markview Toggle<cr>', { desc = '[M]arkview [T]oggle' })
      vim.keymap.set('n', '<leader>ms', '<cmd>Markview splitToggle<cr>', { desc = '[M]arkview [S]plit toggle' })
    end,
  },
  -- Dependencies loaded by lze before their parent plugins
  { 'nui.nvim', dep_of = { 'noice.nvim' } },
}
