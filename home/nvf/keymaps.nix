_: {
  programs.nvf.settings.vim = {
    keymaps = [
      {
        key = "<Esc>";
        mode = ["n"];
        action = "<cmd>nohlsearch<CR>";
        desc = "Clear search highlights";
      }
      {
        key = "[d";
        mode = ["n"];
        action = "vim.diagnostic.goto_prev";
        desc = "Go to previous [D]iagnostic message";
      }
      {
        key = "]d";
        mode = ["n"];
        action = "vim.diagnostic.goto_next";
        desc = "Go to next [D]iagnostic message";
      }
      {
        key = "<leader>e";
        mode = ["n"];
        action = "vim.diagnostic.open_float";
        desc = "Show [D]iagnostic Error message";
      }
      {
        key = "<leader>q";
        mode = ["n"];
        action = "vim.diagnostic.setloclist";
        desc = "Open [D]iagnostic Quickfix list";
      }
      {
        key = "<left>";
        mode = ["n" "i" "v"];
        action = "<cmd>echo 'Use h to move!!'<CR>";
        desc = "Disable arrow keys Left";
      }
      {
        key = "<right>";
        mode = ["n" "i" "v"];
        action = "<cmd>echo 'Use l to move!!'<CR>";
        desc = "Disable arrow keys Right";
      }
      {
        key = "<up>";
        mode = ["n" "i" "v"];
        action = "<cmd>echo 'Use k to move!!'<CR>";
        desc = "Disable arrow keys Up";
      }
      {
        key = "<down>";
        mode = ["n" "i" "v"];
        action = "<cmd>echo 'Use j to move!!'<CR>";
        desc = "Disable arrow keys Down";
      }
      {
        key = "<C-h>";
        mode = ["n"];
        action = "'<C-w><C-h>'";
        desc = "Move focus to left window";
      }
      {
        key = "<C-l>";
        mode = ["n"];
        action = "'<C-w><C-l>'";
        desc = "Move focus to right window";
      }
      {
        key = "<C-j>";
        mode = ["n"];
        action = "'<C-w><C-j>'";
        desc = "Move focus to lower window";
      }
      {
        key = "<C-k>";
        mode = ["n"];
        action = "'<C-w><C-k>'";
        desc = "Move focus to upper window";
      }
      /*

      vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
      vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
      vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
      vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
      -- Diagnostic keymaps
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

      -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
      -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
      -- is not what someone will guess without a bit more experience.
      -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
      -- or just use <C-\><C-n> to exit terminal mode
      vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

      -- TIP: Disable arrow keys in normal mode
      vim.keymap.set({ 'n', 'i', 'v' }, '<left>', '<cmd>echo "Use h to move!!"<CR>')
      vim.keymap.set({ 'n', 'i', 'v' }, '<right>', '<cmd>echo "Use l to move!!"<CR>')
      vim.keymap.set({ 'n', 'i', 'v' }, '<up>', '<cmd>echo "Use k to move!!"<CR>')
      vim.keymap.set({ 'n', 'i', 'v' }, '<down>', '<cmd>echo "Use j to move!!"<CR>')

      -- Keybinds to make split navigation easier.
      --  Use CTRL+<hjkl> to switch between windows
      --  See `:help wincmd` for a list of all window commands
      vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
      vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
      vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
      vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

      vim.keymap.set('i', '<C-CR>', '<Plug>(copilot-suggest)')

      vim.keymap.set('n', '<S-h>', ':bprevious<CR>')
      vim.keymap.set('n', '<S-l>', ':bnext<CR>')
      */
      {
        key = "<leader>ff";
        mode = ["n"];
        action = "<cmd>Telescope find_files<cr>";
        desc = "Search files by name";
      }
      {
        key = "<leader>lg";
        mode = ["n"];
        action = "<cmd>Telescope live_grep<cr>";
        desc = "Search files by contents";
      }
      {
        key = "<leader>fe";
        mode = ["n"];
        action = "<cmd>Neotree toggle<cr>";
        desc = "File browser toggle";
      }
      {
        key = "<C-h>";
        mode = ["i"];
        action = "<Left>";
        desc = "Move left in insert mode";
      }
      {
        key = "<C-j>";
        mode = ["i"];
        action = "<Down>";
        desc = "Move down in insert mode";
      }
      {
        key = "<C-k>";
        mode = ["i"];
        action = "<Up>";
        desc = "Move up in insert mode";
      }
      {
        key = "<C-l>";
        mode = ["i"];
        action = "<Right>";
        desc = "Move right in insert mode";
      }
    ];
  };
}
