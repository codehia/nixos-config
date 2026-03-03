-- =============================================================================
-- EDITOR PLUGINS
-- =============================================================================

return {
  -- ---------------------------------------------------------------------------
  -- Telescope — fuzzy finder
  -- pname: telescope.nvim
  -- ---------------------------------------------------------------------------
  {
    'telescope.nvim',
    event = 'DeferredUIEnter',
    after = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
        )
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
      end, { desc = '[S]earch [/] in Open Files' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Treesitter — syntax highlighting + text objects
  -- pname: nvim-treesitter
  -- ---------------------------------------------------------------------------
  {
    'nvim-treesitter',
    event = 'BufReadPost',
    after = function()
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = '<C-s>',
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
            goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
            goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
            goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
            goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
          },
          swap = {
            enable = true,
            swap_next = { ['<M-l>'] = '@parameter.inner' },
            swap_previous = { ['<M-h>'] = '@parameter.inner' },
          },
        },
      })

      -- Set fold method after treesitter loads to avoid E490 race condition
      -- (setting foldmethod=expr globally before treesitter is ready triggers E490)
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldtext = ''
      vim.opt.foldnestmax = 3
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Gitsigns — inline git blame, hunk staging, diff
  -- pname: gitsigns.nvim
  -- ---------------------------------------------------------------------------
  {
    'gitsigns.nvim',
    event = 'BufReadPost',
    after = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end, { desc = 'Jump to next git [c]hange' })
          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end, { desc = 'Jump to previous git [c]hange' })
          map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
          map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'reset git hunk' })
          map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
          map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
          map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
          map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
          map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
          map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
          map('n', '<leader>hD', function()
            gitsigns.diffthis('@')
          end, { desc = 'git [D]iff against last commit' })
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git [b]lame' })
          map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Oil — file browser replacing netrw
  -- pname: oil.nvim
  -- ---------------------------------------------------------------------------
  {
    'oil.nvim',
    keys = {
      { '-', desc = 'Open parent directory' },
      { '<leader>-', desc = 'Open parent directory (float)' },
    },
    after = function()
      require('oil').setup({
        default_file_explorer = true,
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
          natural_order = true,
          is_always_hidden = function(name, _)
            return name == '..' or name == '.git'
          end,
        },
        float = { padding = 2, max_width = 90, max_height = 0 },
        win_options = { wrap = true, winblend = 0 },
        keymaps = { ['<C-c>'] = false, ['q'] = 'actions.close' },
      })
      vim.keymap.set('n', '<leader>-', require('oil').toggle_float, {
        desc = 'Open parent directory (float)',
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Vim-sleuth — auto-detect indentation
  -- pname: vim-sleuth
  -- ---------------------------------------------------------------------------
  { 'vim-sleuth' },

  -- ---------------------------------------------------------------------------
  -- Harpoon2 — fast file navigation with telescope integration
  -- pname: harpoon2
  -- ---------------------------------------------------------------------------
  {
    'harpoon2',
    keys = {
      { '<leader>a', desc = '[H]arpoon add file' },
      { '<C-e>', desc = '[H]arpoon open telescope' },
      { '<leader>1', desc = '[H]arpoon file 1' },
      { '<leader>2', desc = '[H]arpoon file 2' },
      { '<leader>3', desc = '[H]arpoon file 3' },
      { '<leader>4', desc = '[H]arpoon file 4' },
      { '<leader>p', desc = '[H]arpoon prev' },
      { '<leader>n', desc = '[H]arpoon next' },
    },
    after = function()
      local harpoon = require('harpoon')
      harpoon:setup()

      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end
          return require('telescope.finders').new_table({ results = paths })
        end
        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = finder(),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              map('i', '<C-d>', function()
                local state = require('telescope.actions.state')
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)
                table.remove(harpoon_files.items, selected_entry.index)
                current_picker:refresh(finder())
              end)
              return true
            end,
          })
          :find()
      end

      vim.keymap.set('n', '<C-e>', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open harpoon window' })
      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[H]arpoon add file' })
      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end, { desc = '[H]arpoon file 1' })
      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end, { desc = '[H]arpoon file 2' })
      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end, { desc = '[H]arpoon file 3' })
      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end, { desc = '[H]arpoon file 4' })
      vim.keymap.set('n', '<leader>p', function()
        harpoon:list():prev()
      end, { desc = '[H]arpoon prev' })
      vim.keymap.set('n', '<leader>n', function()
        harpoon:list():next()
      end, { desc = '[H]arpoon next' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Trouble — pretty diagnostics / quickfix list
  -- pname: trouble.nvim
  -- ---------------------------------------------------------------------------
  {
    'trouble.nvim',
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', desc = 'Trouble: diagnostics' },
      { '<leader>xX', desc = 'Trouble: buffer diagnostics' },
      { '<leader>cs', desc = 'Trouble: symbols' },
      { '<leader>cl', desc = 'Trouble: LSP' },
      { '<leader>xL', desc = 'Trouble: loclist' },
      { '<leader>xQ', desc = 'Trouble: quickfix' },
    },
    after = function()
      require('trouble').setup()
      vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Trouble: diagnostics' })
      vim.keymap.set(
        'n',
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
        { desc = 'Trouble: buffer diagnostics' }
      )
      vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Trouble: symbols' })
      vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle<CR>', { desc = 'Trouble: LSP' })
      vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Trouble: loclist' })
      vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Trouble: quickfix' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Todo-comments — highlight TODO/FIXME/etc.
  -- pname: todo-comments.nvim
  -- ---------------------------------------------------------------------------
  {
    'todo-comments.nvim',
    event = 'BufReadPost',
    after = function()
      require('todo-comments').setup()
      vim.keymap.set('n', '<leader>st', function()
        require('telescope.builtin').grep_string({
          search = 'TODO|FIXME|HACK|NOTE|BUG|WARN',
          use_regex = true,
        })
      end, { desc = '[S]earch [T]odo comments' })
      vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<CR>', { desc = 'Trouble: todo list' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Zen-mode + Twilight — distraction-free editing
  -- pnames: zen-mode.nvim, twilight.nvim
  -- ---------------------------------------------------------------------------
  {
    'zen-mode.nvim',
    keys = { { '<leader>zz', desc = '[Z]en mode' } },
    after = function()
      require('twilight').setup()
      require('zen-mode').setup({ plugins = { twilight = { enabled = true } } })
      vim.keymap.set('n', '<leader>zz', '<cmd>ZenMode<CR>', { desc = '[Z]en mode' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Octo — GitHub issues/PRs inside nvim
  -- pname: octo.nvim
  -- ---------------------------------------------------------------------------
  {
    'octo.nvim',
    cmd = 'Octo',
    after = function()
      require('octo').setup({ default_to_projects_v2 = true, picker = 'telescope' })
    end,
  },

  -- Dependencies loaded by lze before their parent plugins
  { 'telescope-fzf-native.nvim', dep_of = { 'telescope.nvim' } },
  { 'telescope-ui-select.nvim', dep_of = { 'telescope.nvim' } },
  { 'twilight.nvim', dep_of = { 'zen-mode.nvim' } },
  -- Loaded after nvim-treesitter (they require it, not the other way around)
  { 'nvim-treesitter-textobjects', on_plugin = { 'nvim-treesitter' } },
}
