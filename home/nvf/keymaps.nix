{lib, ...}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;
in {
  programs.nvf.settings.vim = {
    keymaps = [
      (mkKeymap "n" "<Esc>" "<cmd>nohlsearch<CR>")
    ];
    # mappings = {
    #   workspaceDiagnostics = mkMappingOption "Workspace diagnostics [Trouble]" "<leader>lwd";
    #   hoHlSearch = mkMappingOption "Clear the highlight from search results" "<>"
    # };
  };
}
