-- =============================================================================
-- CODING PLUGINS (LSP, Completion, Formatting, Linting, AI, Debug)
-- =============================================================================

local lzextras = require('lzextras')

return {
  -- ---------------------------------------------------------------------------
  -- Lazydev — improved Lua LSP for neovim config editing
  -- pname: lazydev.nvim
  -- ---------------------------------------------------------------------------
  {
    'lazydev.nvim',
    -- Guard: lazydev enhances lua_ls for Neovim config editing; no value without the lua
    -- category since lua-language-server won't be on PATH and lua_ls won't be configured.
    enabled = nix_has_feature('lua'),
    ft = 'lua',
    after = function()
      require('lazydev').setup({ library = {} })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- blink-cmp — completion engine
  -- pname: blink.cmp
  -- ---------------------------------------------------------------------------
  {
    'blink.cmp',
    event = 'InsertEnter',
    after = function()
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-e>'] = { 'hide' },
          ['<C-y>'] = { 'select_and_accept' },
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
          ['<Tab>'] = { 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },
        snippets = {
          preset = 'luasnip',
        },
        sources = {
          default = { 'lsp', 'snippets', 'copilot', 'buffer' },
          providers = {
            snippets = {
              opts = {
                -- friendly_snippets is loaded by luasnip, not blink.cmp
                -- when using preset = 'luasnip'
              },
            },
            buffer = {
              opts = {
                -- Load completions from all normal buffers (filters out neo-tree, etc.)
                get_bufnrs = function()
                  return vim.tbl_filter(function(bufnr)
                    return vim.bo[bufnr].buftype == ''
                  end, vim.api.nvim_list_bufs())
                end,
              },
            },
            copilot = {
              name = 'copilot',
              module = 'blink-cmp-copilot',
              async = true,
            },
          },
        },
        completion = {
          menu = {
            border = 'rounded',
            draw = {
              components = {
                kind_icon = {
                  text = function(ctx)
                    local icon = ctx.kind_icon
                    if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                      local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                      if dev_icon then
                        icon = dev_icon
                      end
                    else
                      icon = require('lspkind').symbol_map[ctx.kind] or ctx.kind_icon
                    end

                    return icon .. ctx.icon_gap
                  end,
                  -- Optionally, use the highlight groups from nvim-web-devicons
                  -- You can also add the same function for `kind.highlight` if you want to
                  -- keep the highlight groups in sync with the icons.
                  highlight = function(ctx)
                    local hl = ctx.kind_hl
                    if vim.tbl_contains({ 'Path' }, ctx.source_name) then
                      local dev_icon, dev_hl = require('nvim-web-devicons').get_icon(ctx.label)
                      if dev_icon then
                        hl = dev_hl
                      end
                    end
                    return hl
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
            window = { border = 'rounded' },
          },
        },
        signature = {
          enabled = true,
          window = { border = 'rounded' },
        },
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- LuaSnip — snippet engine (provides snippet source for blink-cmp)
  -- pname: luasnip
  -- Load immediately (lazy = false) to ensure availability before blink.cmp
  -- ---------------------------------------------------------------------------
  {
    'luasnip',
    lazy = false,
    after = function()
      local ls = require('luasnip')
      -- Load friendly-snippets using the recommended lazy_load() method
      require('luasnip.loaders.from_vscode').lazy_load()

      ls.config.set_config({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
        enable_autosnippets = true,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Copilot — GitHub Copilot (panel/suggestions off; blink-cmp-copilot handles)
  -- pname: copilot.lua
  -- ---------------------------------------------------------------------------
  {
    'copilot.lua',
    event = { 'InsertEnter' },
    keys = {
      {
        '<leader>tc',
        function()
          if require('copilot.client').is_disabled() then
            require('copilot.command').enable()
            vim.notify('Copilot enabled')
          else
            require('copilot.command').disable()
            vim.notify('Copilot disabled')
          end
        end,
        desc = '[T]oggle [C]opilot',
      },
    },
    after = function()
      require('copilot').setup({
        panel = { enabled = false },
        suggestion = { enabled = false },
      })
      require('copilot.command').disable()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- blink-cmp-copilot — copilot source for blink-cmp (dep, loaded lazily)
  -- pname: blink-cmp-copilot
  -- ---------------------------------------------------------------------------
  {
    'blink-cmp-copilot',
    dep_of = { 'blink.cmp' },
    lazy = true,
  },

  -- ---------------------------------------------------------------------------
  -- CopilotChat — GitHub Copilot chat interface
  -- pname: CopilotChat.nvim
  -- ---------------------------------------------------------------------------
  {
    'CopilotChat.nvim',
    cmd = 'CopilotChat',
    after = function()
      require('CopilotChat').setup({
        model = 'auto',
        question_header = '  User ',
        answer_header = '  Copilot ',
        window = { layout = 'vertical', width = 0.3, border = 'rounded' },
        show_help = true,
        auto_follow_cursor = true,
        auto_insert_mode = false,
        clear_chat_on_new_prompt = false,
        highlight_selection = true,
        context = 'buffer',
        selection_spec = 'visual',
        chat_autocomplete = true,
        separator = '─',
        show_folds = true,
        mappings = {
          close = { insert = '' },
          reset = { normal = '', insert = '' },
          submit_prompt = { normal = '<CR>', insert = '<C-s>' },
          accept_diff = { normal = '<C-y>', insert = '<C-y>' },
          show_diff = { normal = '<leader>ad' },
          show_system_prompt = { normal = '<leader>as' },
          show_user_selection = { normal = '<leader>al' },
        },
      })

      vim.keymap.set({ 'n', 'x' }, '<leader>aa', '<cmd>CopilotChatToggle<CR>', {
        desc = 'CopilotChat: toggle',
      })
      vim.keymap.set({ 'n', 'x' }, '<leader>aq', function()
        vim.ui.input({ prompt = 'Ask AI: ' }, function(input)
          if input and input ~= '' then
            require('CopilotChat').ask(input)
          end
        end)
      end, { desc = 'CopilotChat: quick chat' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ax', function()
        require('CopilotChat').reset()
      end, { desc = 'CopilotChat: reset' })
      vim.keymap.set({ 'n', 'x' }, '<leader>ap', function()
        local ok, integ = pcall(require, 'CopilotChat.integrations.telescope')
        if ok then
          integ.pick(require('CopilotChat.actions').prompt_actions())
        end
      end, { desc = 'CopilotChat: prompt actions' })

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-chat',
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Lspsaga — enhanced LSP UI (owns K, <leader>ca, <leader>rn)
  -- pname: lspsaga.nvim
  -- ---------------------------------------------------------------------------

  {
    'lspsaga.nvim',
    event = 'LspAttach',
    after = function()
      require('lspsaga').setup({
        lightbulb = { enable = true },
        ui = { border = 'rounded' },
        rename = { in_select = true },
      })
      vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { desc = 'LSP: Hover Documentation' })
      vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', { desc = 'LSP: [C]ode [A]ction' })
      vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<CR>', { desc = 'LSP: [R]e[n]ame' })
      vim.keymap.set(
        'n',
        '<leader>rN',
        '<cmd>Lspsaga rename ++project<CR>',
        { desc = 'LSP: [R]e[N]ame (project-wide)' }
      )
      vim.keymap.set('n', '<leader>pd', '<cmd>Lspsaga peek_definition<CR>', { desc = 'LSP: [P]eek [D]efinition' })
      vim.keymap.set('n', '<leader>lo', '<cmd>Lspsaga outline<CR>', { desc = 'LSP: [O]utline' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Conform — format on save
  -- pname: conform.nvim
  -- ---------------------------------------------------------------------------
  {
    'conform.nvim',
    event = 'BufWritePre',
    after = function()
      local fmt = require('config.format')

      -- Build formatters_by_ft from Nix-provided fast + slow metadata
      local formatters_by_ft = {}
      local fast_info = nix_info('formatters', 'fast')
      local slow_info = nix_info('formatters', 'slow')

      if type(fast_info) == 'table' then
        for ft, fmts in pairs(fast_info) do
          formatters_by_ft[ft] = formatters_by_ft[ft] or {}
          for _, f in ipairs(fmts) do
            table.insert(formatters_by_ft[ft], f)
          end
        end
      end
      if type(slow_info) == 'table' then
        for ft, fmts in pairs(slow_info) do
          formatters_by_ft[ft] = formatters_by_ft[ft] or {}
          for _, f in ipairs(fmts) do
            table.insert(formatters_by_ft[ft], f)
          end
        end
      end

      require('conform').setup({
        notify_on_error = false,
        -- Use the format dispatcher for on-save: fast only (sync)
        format_on_save = function(bufnr)
          fmt.format_fast(bufnr)
          return nil -- we handled formatting ourselves
        end,
        formatters_by_ft = formatters_by_ft,
      })

      -- <leader>cf: run all formatters (fast sync + slow async)
      vim.keymap.set('n', '<leader>cf', function()
        fmt.format_all()
      end, { desc = '[C]ode [F]ormat (all)' })

      -- <leader>cF: run only slow formatters (async)
      vim.keymap.set('n', '<leader>cF', function()
        fmt.format_slow()
      end, { desc = '[C]ode [F]ormat (slow)' })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-lint — async linting (dynamic from Nix)
  -- pname: nvim-lint
  -- ---------------------------------------------------------------------------
  {
    'nvim-lint',
    event = 'BufReadPost',
    after = function()
      local lint = require('lint')

      -- Build linters_by_ft from Nix-provided metadata
      local linters_by_ft = {}
      local linters_info = nix_info('linters')
      if type(linters_info) == 'table' then
        for ft, lints in pairs(linters_info) do
          linters_by_ft[ft] = lints
        end
      end
      lint.linters_by_ft = linters_by_ft

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-dap — debug adapter protocol
  -- pname: nvim-dap
  -- ---------------------------------------------------------------------------
  {
    'nvim-dap',
    keys = {
      lzextras.key2spec('n', '<F5>', function()
        require('dap').continue()
      end, { desc = 'Debug: Start/Continue' }),
      lzextras.key2spec('n', '<F10>', function()
        require('dap').step_over()
      end, { desc = 'Debug: Step Over' }),
      lzextras.key2spec('n', '<F11>', function()
        require('dap').step_into()
      end, { desc = 'Debug: Step Into' }),
      lzextras.key2spec('n', '<F12>', function()
        require('dap').step_out()
      end, { desc = 'Debug: Step Out' }),
      lzextras.key2spec('n', '<leader>db', function()
        require('dap').toggle_breakpoint()
      end, { desc = 'Debug: Toggle Breakpoint' }),
      lzextras.key2spec('n', '<leader>dB', function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = 'Debug: Set Breakpoint' }),
      lzextras.key2spec('n', '<leader>du', function()
        require('dapui').toggle()
      end, { desc = 'Debug: Toggle UI' }),
    },
    after = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
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
      })

      require('nvim-dap-virtual-text').setup({
        enabled = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
        virt_text_pos = vim.fn.has('nvim-0.10') == 1 and 'inline' or 'eol',
      })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },

  -- ---------------------------------------------------------------------------
  -- nvim-dap-go — Go DAP adapter
  -- pname: nvim-dap-go
  -- ---------------------------------------------------------------------------
  {
    'nvim-dap-go',
    -- Guard: needs dlv (Go debugger) on PATH, which is only present when go is in the
    -- `languages` list in nvim.nix. Without this, lze would load the plugin but it
    -- would error trying to configure an adapter whose binary doesn't exist.
    enabled = nix_has_feature('go'),
    on_plugin = { 'nvim-dap' },
    after = function()
      require('dap-go').setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- Avante — AI assistant (Claude)
  -- pname: avante.nvim
  -- Loads after UI renders (DeferredUIEnter) — no VeryLazy in lze
  -- ---------------------------------------------------------------------------
  {
    'avante.nvim',
    event = 'DeferredUIEnter',
    after = function()
      require('avante').setup({
        -- provider = "claude",
        providers = {
          claude = {
            endpoint = 'https://api.anthropic.com',
            model = 'claude-sonnet-4-20250514',
            timeout = 30000, -- Timeout in milliseconds
            extra_request_body = {
              temperature = 0.75,
              max_tokens = 20480,
            },
          },
        },
        behaviour = {
          auto_suggestions = false,
          auto_set_highlight_group = true,
          auto_set_keymaps = true,
          auto_apply_diff_after_generation = false,
        },
        mappings = {
          ask = '<leader>aa',
          edit = '<leader>ae',
          refresh = '<leader>ar',
        },
        hints = { enabled = true },
        windows = {
          position = 'right',
          wrap = true,
          width = 30,
          sidebar_header = { align = 'center', rounded = true },
        },
        highlights = { diff = { current = 'DiffText', incoming = 'DiffAdd' } },
        diff = { autojump = true, list_opener = 'copen' },
      })
    end,
  },

  -- Dependencies loaded by lze before their parent plugins
  { 'nvim-nio', dep_of = { 'nvim-dap-ui' } },
  { 'nvim-dap-ui', dep_of = { 'nvim-dap' } },
  { 'nvim-dap-virtual-text', dep_of = { 'nvim-dap' } },
  { 'render-markdown.nvim', dep_of = { 'avante.nvim' } },
  { 'img-clip.nvim', dep_of = { 'avante.nvim' } },
  { 'fzf-lua', dep_of = { 'avante.nvim' } },
  { 'friendly-snippets', dep_of = { 'luasnip' } },
}
