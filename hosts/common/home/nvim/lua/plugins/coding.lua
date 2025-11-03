-- =============================================================================
-- CODING PLUGINS (Completion, LSP, Linting, Formatting)
-- =============================================================================

return {
  -- Completion
  {
    'blink-cmp',
    event = 'InsertEnter',
    after = function()
      require('blink-cmp').setup({
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

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        completion = {
          menu = {
            border = 'rounded',
          },
          documentation = {
            auto_show = true,
            window = {
              border = 'rounded',
            },
          },
        },

        signature = {
          enabled = true,
          window = {
            border = 'rounded',
          },
        },
      })
    end,
  },

  -- LSP Configuration
  {
    'nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    after = function()
      require('config.lsp').setup()
    end,
  },

  -- Formatting
  {
    'conform-nvim',
    event = { 'BufWritePre' },
    after = function()
      -- Smart selection of Python formatters based on availability
      local python_formatters = { 'autopep8' }
      if vim.fn.executable('autopep8') == 0 and vim.fn.executable('black') == 1 then
        python_formatters = { 'isort', 'black' }
      end

      require('conform').setup({
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'fallback'
          end
          return {
            timeout_ms = 500,
            lsp_format = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          python = {'isort', 'autopep8'},
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          nix = { 'nixfmt' },
        },
      })

      vim.keymap.set('n', '<leader>cf', function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end, { desc = '[C]ode [F]ormat' })
    end,
  },

  -- Linting
  {
    'nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    after = function()
      local lint = require('lint')

      -- Smart selection of Python linter based on availability
      local python_linter = 'flake8'
      if vim.fn.executable('flake8') == 0 and vim.fn.executable('ruff') == 1 then
        python_linter = 'ruff'
      end

      lint.linters_by_ft = {
        python = { python_linter },
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      -- Create autocommand which carries out the actual linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Debug Adapter Protocol
  {
    'nvim-dap',
    event = 'VeryLazy',
    after = function()
      local dap = require('dap')

      -- Python DAP configuration
      if nixCats('python') then
        dap.adapters.python = {
          type = 'executable',
          command = 'python',
          args = { '-m', 'debugpy.adapter' },
        }
        dap.configurations.python = {
          {
            type = 'python',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            pythonPath = function()
              return 'python'
            end,
          },
        }
      end

      -- Go DAP configuration
      if nixCats('go') then
        dap.adapters.delve = {
          type = 'server',
          port = '${port}',
          executable = {
            command = 'dlv',
            args = { 'dap', '-l', '127.0.0.1:${port}' },
          },
        }
        dap.configurations.go = {
          {
            type = 'delve',
            name = 'Debug',
            request = 'launch',
            program = '${file}',
          },
        }
      end

      -- DAP keymaps
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug: Toggle [B]reakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = '[D]ebug: Set [B]reakpoint' })
    end,
  },
}
