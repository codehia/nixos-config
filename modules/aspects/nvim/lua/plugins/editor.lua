-- =============================================================================
-- EDITOR PLUGINS
-- =============================================================================

local lzextras = require('lzextras')

-- SELECT fires on every list:select() (including prev/next), so this tracks
-- the last two visited harpoon indices for the <leader>hl toggle
local harpoon_recent = { cur = nil, prev = nil }

local function harpoon_telescope()
  local harpoon = require('harpoon')
  local conf = require('telescope.config').values
  local harpoon_files = harpoon:list()
  local function finder()
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
      vim.keymap.set('n', '<leader>sF', function()
        builtin.find_files({ hidden = true })
      end, { desc = '[S]earch [F]iles (include hidden)' })
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
      -- <leader>sG — live grep with glob filter (excludes hidden files/dirs)
      -- <leader>sH — same but includes hidden files (dotfiles, .git, etc.)
      --   files only:  *.py          (search only in Python files)
      --   text only:   use <leader>sg instead (no glob needed)
      --   combo:       *.py          then type regex in the grep prompt
      --   multi-glob:  *.py,*.pyi    (comma-separated)
      --   exclude:     !*.test.py    (bang prefix excludes)
      local function grep_with_glob(hidden)
        vim.ui.input({ prompt = 'Glob (e.g. *.py  *.py,*.pyi  !*.test.py): ' }, function(glob)
          if glob and glob ~= '' then
            local opts = { glob_pattern = glob, prompt_title = 'Live Grep (' .. glob .. ')' }
            if hidden then
              opts.additional_args = { '--hidden' }
            end
            builtin.live_grep(opts)
          end
        end)
      end
      vim.keymap.set('n', '<leader>sG', function()
        grep_with_glob(false)
      end, { desc = '[S]earch by [G]rep with glob filter' })
      vim.keymap.set('n', '<leader>sH', function()
        grep_with_glob(true)
      end, { desc = '[S]earch by grep with glob filter (include [H]idden)' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Treesitter — syntax highlighting + text objects
  -- pname: nvim-treesitter
  -- ---------------------------------------------------------------------------
  {
    'nvim-treesitter',
    event = 'BufReadPost',
    -- other plugins (e.g. markview's healthcheck) probe via require('nvim-treesitter')
    on_require = { 'nvim-treesitter' },
    -- main-branch rewrite (nixpkgs 26.05+): the configs module and its setup()
    -- API are gone. Highlighting/folds are native Neovim features enabled per
    -- buffer; the plugin only ships queries, parser management and indentexpr.
    after = function()
      local function attach(buf, ft)
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        -- indentexpr is the plugin's (experimental) replacement for indent.enable
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
        callback = function(args)
          attach(args.buf, args.match)
        end,
      })

      -- The buffer that triggered this load may have fired FileType already
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
          attach(buf, vim.bo[buf].filetype)
        end
      end

      -- Set fold method after treesitter loads to avoid E490 race condition
      -- (setting foldmethod=expr globally before treesitter is ready triggers E490)
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldtext = ''
      vim.opt.foldnestmax = 3
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Treesitter textobjects — select/move/swap (main-branch module API)
  -- pname: nvim-treesitter-textobjects
  -- Loaded after nvim-treesitter (it requires it, not the other way around)
  -- ---------------------------------------------------------------------------
  {
    'nvim-treesitter-textobjects',
    on_plugin = { 'nvim-treesitter' },
    after = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select_maps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      }
      for lhs, query in pairs(select_maps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
        end)
      end

      local move_maps = {
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      }
      for method, maps in pairs(move_maps) do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
          end)
        end
      end

      vim.keymap.set('n', '<M-l>', function()
        require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner')
      end)
      vim.keymap.set('n', '<M-h>', function()
        require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner')
      end)
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Rainbow delimiters — bracket colors per nesting depth (treesitter-based)
  -- pname: rainbow-delimiters.nvim
  -- ---------------------------------------------------------------------------
  {
    'rainbow-delimiters.nvim',
    event = 'BufReadPost',
    -- the plugin's own FileType autocmd handles future buffers; the buffer
    -- that triggered this lazy load fired FileType already, so attach manually
    after = function()
      local config = require('rainbow-delimiters.config')
      local lib = require('rainbow-delimiters.lib')
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ft = vim.bo[buf].filetype
        if vim.api.nvim_buf_is_loaded(buf) and ft ~= '' then
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and config.enabled_for(lang) and config.enabled_when(buf) then
            lib.attach(buf)
          end
        end
      end
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
        preview_config = { border = 'rounded' },

        -- Option 1 (thin bar):
        -- signs = { add={text='▎'}, change={text='▎'}, delete={text='▸'}, topdelete={text='▴'}, changedelete={text='▎'} }
        -- Option 2 (nerd font icons — plus-circle, pencil, minus-circle, minus-square, pencil-square):
        signs = {
          add = { text = '▌' },
          change = { text = '▌' },
          delete = { text = '▂' },
          topdelete = { text = '▔' },
          changedelete = { text = '▌' },
          untracked = { text = '▎' },
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
          map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
          map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
          map('v', '<leader>gs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'stage git hunk' })
          map('v', '<leader>gr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'reset git hunk' })
          map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
          map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
          map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
          map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
          map('n', '<leader>gb', gitsigns.blame_line, { desc = 'git [b]lame line' })
          map('n', '<leader>gt', gitsigns.toggle_current_line_blame, { desc = 'git [t]oggle line blame' })
          map('n', '<leader>gT', gitsigns.toggle_deleted, { desc = 'git [T]oggle show deleted' })
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Diffview — full-tab diff view + file/branch history
  -- pname: diffview.nvim
  -- ---------------------------------------------------------------------------
  {
    'diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    keys = {
      lzextras.key2spec('n', '<leader>gd', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd.DiffviewOpen()
        else
          vim.cmd.DiffviewClose()
        end
      end, { desc = 'Git [d]iffview (toggle)' }),
      lzextras.key2spec('n', '<leader>gf', '<cmd>DiffviewFileHistory %<CR>', { desc = 'Git [f]ile history' }),
      lzextras.key2spec('n', '<leader>gF', '<cmd>DiffviewFileHistory<CR>', { desc = 'Git repo history' }),
    },
    after = function()
      require('diffview').setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Oil — file browser replacing netrw
  -- pname: oil.nvim
  -- ---------------------------------------------------------------------------
  {
    'oil.nvim',
    event = 'DeferredUIEnter',
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
        keymaps = {
          ['<C-c>'] = false,
          ['q'] = 'actions.close',
          ['<BS>'] = 'actions.parent',
        },
      })
      vim.keymap.set('n', '<leader>-', function()
        require('oil').toggle_float()
      end, { desc = 'Open file browser (float)' })
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
      lzextras.key2spec('n', '<C-e>', harpoon_telescope, { desc = '[H]arpoon open telescope' }),
      lzextras.key2spec('n', '<leader>hh', harpoon_telescope, { desc = '[H]arpoon open telescope' }),
      lzextras.key2spec('n', '<leader>ha', function()
        require('harpoon'):list():add()
      end, { desc = '[H]arpoon add file' }),
      lzextras.key2spec('n', '<leader>h1', function()
        require('harpoon'):list():select(1)
      end, { desc = '[H]arpoon file 1' }),
      lzextras.key2spec('n', '<leader>h2', function()
        require('harpoon'):list():select(2)
      end, { desc = '[H]arpoon file 2' }),
      lzextras.key2spec('n', '<leader>h3', function()
        require('harpoon'):list():select(3)
      end, { desc = '[H]arpoon file 3' }),
      lzextras.key2spec('n', '<leader>h4', function()
        require('harpoon'):list():select(4)
      end, { desc = '[H]arpoon file 4' }),
      lzextras.key2spec('n', '<leader>hp', function()
        require('harpoon'):list():prev()
      end, { desc = '[H]arpoon prev' }),
      lzextras.key2spec('n', '<leader>hn', function()
        require('harpoon'):list():next()
      end, { desc = '[H]arpoon next' }),
      lzextras.key2spec('n', '<leader>hl', function()
        if harpoon_recent.prev then
          require('harpoon'):list():select(harpoon_recent.prev)
        else
          vim.notify('No previous harpoon file', vim.log.levels.INFO)
        end
      end, { desc = '[H]arpoon toggle [l]ast' }),
    },
    after = function()
      local harpoon = require('harpoon')
      harpoon:setup()
      harpoon:extend({
        SELECT = function(ev)
          if ev.idx and ev.idx ~= harpoon_recent.cur then
            harpoon_recent.prev = harpoon_recent.cur
            harpoon_recent.cur = ev.idx
          end
        end,
      })
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
      lzextras.key2spec('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Trouble: diagnostics' }),
      lzextras.key2spec(
        'n',
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
        { desc = 'Trouble: buffer diagnostics' }
      ),
      lzextras.key2spec('n', '<leader>cs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Trouble: symbols' }),
      lzextras.key2spec('n', '<leader>cl', '<cmd>Trouble lsp toggle<CR>', { desc = 'Trouble: LSP' }),
      lzextras.key2spec('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Trouble: loclist' }),
      lzextras.key2spec('n', '<leader>xQ', '<cmd>Trouble qflist toggle<CR>', { desc = 'Trouble: quickfix' }),
    },
    after = function()
      require('trouble').setup()
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
    keys = {
      lzextras.key2spec('n', '<leader>zz', '<cmd>ZenMode<CR>', { desc = '[Z]en mode' }),
    },
    after = function()
      require('twilight').setup()
      require('zen-mode').setup({ plugins = { twilight = { enabled = true } } })
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
  { 'nvim-web-devicons', dep_of = { 'diffview.nvim' } },
  { 'telescope-ui-select.nvim', dep_of = { 'telescope.nvim' } },
  { 'twilight.nvim', dep_of = { 'zen-mode.nvim' } },
}
