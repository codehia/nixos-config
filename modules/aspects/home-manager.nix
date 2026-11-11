# Home-manager integration — declares the flake input and sets default home-manager config.
#
# Home-manager turns on for a host when a user has "homeManager" in classes (schema.nix
# defaults every user to it). Accounts come from den.batteries.define-user.
{ den, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den = {
    # Host-side HM settings, on every host that enables home-manager.
    aspects.hm-host.nixos.home-manager = {
      backupFileExtension = "hm-backup";
      # Homes reuse the host's pkgs (overlays + unfree predicate) instead of
      # evaluating nixpkgs again per user.
      useGlobalPkgs = true;
    };
    schema.hm-host.includes = [ den.aspects.hm-host ];

    default.homeManager =
      { config, ... }:
      {
        xdg = {
          enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            projects = "${config.home.homeDirectory}/workspace";
            desktop = null;
            templates = null;
            publicShare = null;
          };
        };
        gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        xresources.path = "${config.xdg.configHome}/X11/xresources";
        home = {
          preferXdgDirectories = true;
          sessionVariables = {
            CARGO_HOME = "$HOME/.local/share/cargo";
            RUSTUP_HOME = "$HOME/.local/share/rustup";
            BUN_INSTALL = "$HOME/.local/share/bun";
            DOTNET_CLI_HOME = "$HOME/.local/share/dotnet";
            IPYTHONDIR = "$HOME/.config/ipython";
            LESSHISTFILE = "$HOME/.local/state/less/history";
            NODE_REPL_HISTORY = "$HOME/.local/state/node_repl_history";
            NPM_CONFIG_USERCONFIG = "$HOME/.config/npm/npmrc";
            CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
            DOCKER_CONFIG = "${config.xdg.configHome}/docker";
            PARALLEL_HOME = "${config.xdg.configHome}/parallel";
            PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
            HISTFILE = "${config.xdg.stateHome}/bash/history";
          };
          # npmrc supports ''${VAR} env substitution only — no shell :-defaults;
          # unexpanded values become literal relative dirs in whatever cwd npm runs
          file.".config/npm/npmrc".text = ''
            cache=${config.xdg.cacheHome}/npm
            prefix=${config.xdg.dataHome}/npm
          '';
        };
      };
  };
}
