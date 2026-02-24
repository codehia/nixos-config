{ pkgs, ... }:

{
  languages = {
    nix.enable = true;
    lua.enable = true;
  };
  packages = with pkgs; [
    git
    nixfmt
    stylua
    prek
  ];

  git-hooks.hooks = {
    # Enable standard shell checks
    shellcheck.enable = true;
    # Formatter for Nix files
    nixfmt.enable = true;
    # Formatter for Lua files
    stylua.enable = true;
  };
}
