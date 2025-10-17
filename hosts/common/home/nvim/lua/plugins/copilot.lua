-- =============================================================================
-- GITHUB COPILOT (Disabled by default)
-- =============================================================================
-- Press <leader>tc to enable Copilot
-- Press <leader>tC to enable Copilot Chat

return {
  -- GitHub Copilot
  {
    'copilot-vim',
    load = function()
      -- Copilot is disabled by default
      vim.g.copilot_enabled = false
      
      -- Keymap to toggle Copilot
      vim.keymap.set('n', '<leader>tc', function()
        if vim.g.copilot_enabled then
          vim.cmd('Copilot disable')
          vim.g.copilot_enabled = false
          vim.notify('Copilot disabled', vim.log.levels.INFO)
        else
          vim.cmd('Copilot enable')
          vim.g.copilot_enabled = true
          vim.notify('Copilot enabled', vim.log.levels.INFO)
        end
      end, { desc = '[T]oggle [C]opilot' })
      
      -- Copilot configuration
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      -- Accept suggestion with <C-l>
      vim.keymap.set('i', '<C-l>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion',
      })
      
      -- Navigate suggestions
      vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)', { desc = 'Next Copilot suggestion' })
      vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)', { desc = 'Previous Copilot suggestion' })
      vim.keymap.set('i', '<C-h>', '<Plug>(copilot-dismiss)', { desc = 'Dismiss Copilot suggestion' })
    end,
  },

  -- Copilot Chat
  {
    'CopilotChat-nvim',
    load = function()
      local chat = require('CopilotChat')
      
      chat.setup({
        debug = false,
        show_help = 'yes',
        prompts = {
          Explain = 'Explain how it works.',
          Review = 'Review the following code and provide concise suggestions.',
          Tests = 'Briefly explain how the selected code works, then generate unit tests.',
          Refactor = 'Refactor the code to improve clarity and readability.',
          FixCode = 'Fix the code to make it work as intended.',
          FixError = 'Explain the error in the code and provide a fix.',
          BetterNamings = 'Provide better names for the variables and functions.',
          Documentation = 'Provide documentation for the following code.',
          SwaggerApiDocs = 'Provide Swagger API documentation for the following code.',
          SwaggerJsDocs = 'Write JSDoc for the following code.',
        },
        -- Auto-trigger Copilot Chat is disabled by default
        auto_insert_mode = false,
        question_header = '## User ',
        answer_header = '## Copilot ',
        error_header = '## Error ',
        separator = '───',
        window = {
          layout = 'vertical', -- 'vertical', 'horizontal', 'float'
          width = 0.4,
          height = 0.6,
          relative = 'editor',
        },
      })

      -- Copilot Chat keymaps
      vim.keymap.set('n', '<leader>tC', function()
        chat.toggle()
      end, { desc = '[T]oggle [C]opilot Chat' })
      
      vim.keymap.set('n', '<leader>ccq', function()
        local input = vim.fn.input('Quick Chat: ')
        if input ~= '' then
          chat.ask(input, { selection = require('CopilotChat.select').buffer })
        end
      end, { desc = '[C]opilot [C]hat [Q]uick chat' })
      
      vim.keymap.set('n', '<leader>cch', function()
        local actions = require('CopilotChat.actions')
        require('CopilotChat.integrations.telescope').pick(actions.help_actions())
      end, { desc = '[C]opilot [C]hat [H]elp actions' })
      
      vim.keymap.set('n', '<leader>ccp', function()
        local actions = require('CopilotChat.actions')
        require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
      end, { desc = '[C]opilot [C]hat [P]rompt actions' })
      
      -- Visual mode prompts
      vim.keymap.set('v', '<leader>cce', function()
        chat.ask('Explain how it works.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat [E]xplain' })
      
      vim.keymap.set('v', '<leader>ccr', function()
        chat.ask('Review the following code and provide concise suggestions.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat [R]eview' })
      
      vim.keymap.set('v', '<leader>ccf', function()
        chat.ask('Fix the code to make it work as intended.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat [F]ix' })
      
      vim.keymap.set('v', '<leader>cco', function()
        chat.ask('Refactor the code to improve clarity and readability.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat Refact[o]r' })
      
      vim.keymap.set('v', '<leader>cct', function()
        chat.ask('Generate unit tests for this code.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat [T]ests' })
      
      vim.keymap.set('v', '<leader>ccd', function()
        chat.ask('Provide documentation for the following code.', { selection = require('CopilotChat.select').visual })
      end, { desc = '[C]opilot [C]hat [D]ocumentation' })
      
      -- Buffer and diagnostic prompts
      vim.keymap.set('n', '<leader>ccb', function()
        chat.ask('Explain this buffer', { selection = require('CopilotChat.select').buffer })
      end, { desc = '[C]opilot [C]hat [B]uffer' })
      
      vim.keymap.set('n', '<leader>ccx', function()
        chat.ask('Explain the diagnostic', { selection = require('CopilotChat.select').diagnostic })
      end, { desc = '[C]opilot [C]hat Diagnostic' })
    end,
  },
}
