# Home-manager integration — declares the flake input and sets default home-manager config.
#
# Home-manager is now enabled per-host via den.hosts.<system>.<hostname>.home-manager.enable = true.
# User accounts are created automatically by den when users are declared in den.hosts.
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.default = {
    nixos.home-manager.backupFileExtension = "hm-backup";

    homeManager =
      { config, ... }:
      {
        xdg.enable = true;
        xdg.userDirs = {
          enable = true;
          createDirectories = true;
          music = "${config.home.homeDirectory}/Media/Music";
        };
        home.sessionVariables = {
          CARGO_HOME = "$HOME/.local/share/cargo";
          RUSTUP_HOME = "$HOME/.local/share/rustup";
          BUN_INSTALL = "$HOME/.local/share/bun";
          DOTNET_CLI_HOME = "$HOME/.local/share/dotnet";
          IPYTHONDIR = "$HOME/.config/ipython";
          LESSHISTFILE = "$HOME/.local/state/less/history";
          NODE_REPL_HISTORY = "$HOME/.local/state/node_repl_history";
          NPM_CONFIG_USERCONFIG = "$HOME/.config/npm/npmrc";
          COOKIECUTTER_CONFIG = "$HOME/.config/cookiecutter/config.yaml";
        };
        home.file.".config/npm/npmrc".text = ''
          cache=''${XDG_CACHE_HOME:-$HOME/.cache}/npm
          prefix=''${XDG_DATA_HOME:-$HOME/.local/share}/npm
        '';
      };
  };
}
