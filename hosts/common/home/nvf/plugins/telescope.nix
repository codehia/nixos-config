{ pkgs, ... }: {
  programs.nvf.settings.vim.telescope = {
    enable = true;
    extensions = [{
      name = "fzf";
      packages = with pkgs; [ vimPlugins.telescope-fzf-native-nvim ];
      setup = { fzf = { fuzzy = true; }; };
    }];
  };
}
