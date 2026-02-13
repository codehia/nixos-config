{pkgs, ...}: {
  packages = [pkgs.git];
  languages = {
    lua = {
      enable = true;
      lsp.enable = true;
    };
    nix = {
      enable = true;
      lsp.enable = true;
    };
  };

  git-hooks.hooks = {
    lua-ls.enable = true;
    alejandra.enable = true;
  };
}
