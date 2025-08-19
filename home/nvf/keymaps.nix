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
        action = "<C-w><C-h>";
        desc = "Move focus to left window";
      }
      {
        key = "<C-l>";
        mode = ["n"];
        action = "<C-w><C-l>";
        desc = "Move focus to right window";
      }
      {
        key = "<C-j>";
        mode = ["n"];
        action = "<C-w><C-j>";
        desc = "Move focus to lower window";
      }
      {
        key = "<C-k>";
        mode = ["n"];
        action = "<C-w><C-k>";
        desc = "Move focus to upper window";
      }
      {
        key = "<S-h>";
        mode = ["n"];
        action = ":bprevious<CR>";
        desc = "Focus previous buffer";
      }
      {
        key = "<S-l>";
        mode = ["n"];
        action = ":bnext<CR>";
        desc = "Focus next buffer";
      }
      # Telescope keymaps
      {
        key = "<leader>sh";
        mode = ["n"];
        action = "<cmd>Telescope help_tags<cr>";
        desc = "[S]earch [H]elp";
      }
      {
        key = "<leader>sk";
        mode = ["n"];
        action = "<cmd>Telescope keymaps<cr>";
        desc = "[S]earch [K]eymaps";
      }
      {
        key = "<leader>sf";
        mode = ["n"];
        action = "<cmd>Telescope find_files<cr>";
        desc = "[S]earch [F]iles";
      }
      {
        key = "<leader>ss";
        mode = ["n"];
        action = "<cmd>Telescope builtin<cr>";
        desc = "[S]earch [S]elect Telescope";
      }
      {
        key = "<leader>sw";
        mode = ["n"];
        action = "<cmd>Telescope grep_string<cr>";
        desc = "[S]earch current [W]ord";
      }
      {
        key = "<leader>sg";
        mode = ["n"];
        action = "<cmd>Telescope live_grep<cr>";
        desc = "[S]earch by [G]rep";
      }
      {
        key = "<leader>sd";
        mode = ["n"];
        action = "<cmd>Telescope diagnostics<cr>";
        desc = "[S]earch [D]iagnostics";
      }
      {
        key = "<leader>sr";
        mode = ["n"];
        action = "<cmd>Telescope resume<cr>";
        desc = "[S]earch [R]esume";
      }
      {
        key = "<leader>s.";
        mode = ["n"];
        action = "<cmd>Telescope oldfiles<cr>";
        desc = "[S]earch Recent Files ('.' for repeat)";
      }
      {
        key = "<leader>sm";
        mode = ["n"];
        action = "<cmd>Telescope marks<cr>";
        desc = "[S]earch [M]arks";
      }
      {
        key = "<leader><leader>";
        mode = ["n"];
        action = "<cmd>Telescope buffers<cr>";
        desc = "[] Find existing buffers";
      }
      {
        key = "<leader>/";
        mode = ["n"];
        action = ''
          function()
            local builtin = require 'telescope.builtin'
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false, })
          end
        '';
        lua = true;
        desc = "[/] Fuzzily search in current buffer";
      }
      {
        key = "<leader>s/";
        mode = ["n"];
        action = ''
          function()
            local builtin = require 'telescope.builtin'
            builtin.live_grep {
               grep_open_files = true,
               prompt_title = 'Live Grep in Open Files',
            }
          end
        '';
        lua = true;
        desc = "[S]earch in  [/] Open Files";
      }
    ];
  };
}
