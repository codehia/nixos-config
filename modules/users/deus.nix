# User aspect — defines the "deus" user identity and selects all feature aspects.
#
# Feature aspects live here so their homeManager config flows via ctx.user → HM.
# Host-specific aspect selection (wm, extraAspects) is driven by freeform host attrs.
{ den, ... }:
let
  inherit (den.lib) perUser;

  wmSelector =
    { host, ... }:
    {
      includes = [ den.aspects.${host.wm} ];
    };
  extraAspectsSelector =
    { host, ... }:
    {
      includes = map (a: den.aspects.${a}) (host.extraAspects or [ ]);
    };
in
{
  den.aspects.deus = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")

      # Theming
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.cursor

      # Terminal / shell
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.kitty
      den.aspects.tmux

      # Window manager — host.wm selects the aspect by name
      (perUser wmSelector)

      # Editor / dev
      den.aspects.git
      den.aspects.lazygit
      den.aspects.nvim
      den.aspects.direnv
      den.aspects.dev-tools

      # Browser
      den.aspects.browser

      # Secrets / SSH
      den.aspects.secrets
      den.aspects.ssh

      # Packages and tools
      den.aspects.packages
      den.aspects.services
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.productivity
      den.aspects.media
      den.aspects.creative
      den.aspects.chat
      den.aspects.calibre
      den.aspects.qbittorrent
      den.aspects.dms-home

      # User-level services
      den.aspects.rclone

      # Host-specific extras — host.extraAspects is a list of aspect name strings
      (perUser extraAspectsSelector)
    ];

    nixos.users.users.deus = {
      description = "Soumyaranjan Acharya";
      initialPassword = "REDACTED";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8QcSgwXXrWmVdjcDcKZbBPkQWybWAZih/8YjFno+cK dev@sacharya.dev"
      ];
    };

    homeManager.home = {
      homeDirectory = "/home/deus";
      sessionVariables.BROWSER = "zen";
    };
    homeManager.programs.git.settings.user = {
      name = "codehia";
      email = "dev@sacharya.dev";
    };
  };
}
