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
      den.aspects.appearance

      # Terminal / shell
      den.aspects.terminal

      # Window manager — host.wm selects the aspect by name
      (perUser wmSelector)

      # Editor / dev
      den.aspects.vcs
      den.aspects.editor
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
      den.aspects.apps
      den.aspects.qbittorrent
      den.aspects.dms-home

      # Host-specific extras — aspects needed on only some hosts, not all.
      # Add aspect name strings to host.extraAspects; extraAspectsSelector resolves
      # them to den.aspects.${name} at eval time. Aspects needed on ALL hosts must
      # be listed directly in includes above — putting them in extraAspects instead
      # silently omits them from any host that doesn't declare the name.
      (perUser extraAspectsSelector)
    ];

    nixos =
      { config, ... }:
      {
        sops.secrets.deus_password = {
          sopsFile = ../../secrets/deus.yaml;
          key = "user_password";
          neededForUsers = true;
        };
        users.users.deus = {
          description = "Soumyaranjan Acharya";
          hashedPasswordFile = config.sops.secrets.deus_password.path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8QcSgwXXrWmVdjcDcKZbBPkQWybWAZih/8YjFno+cK dev@sacharya.dev"
          ];
        };
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
