_: {
  programs.nvf.settings.vim = {
    keymaps = [
      {
        key = "<Esc>";
        mode = ["n"];
        action = ":nohl<CR>";
        desc = "Clear search highlights";
      }
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
