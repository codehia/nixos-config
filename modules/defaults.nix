# Global defaults — config applied to every host and user.
# den.default sets baseline NixOS and home-manager options across all hosts.
{ den, ... }:
let
  trustedUsers =
    { user, ... }:
    {
      nixos.nix.settings.trusted-users = [ user.userName ];
    };
in
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    nixos.time.timeZone = "Asia/Kolkata";
    nixos.i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocales = [ "all" ];
    };
    homeManager.home.stateVersion = "25.11";
    includes = [
      den.provides.define-user
      den.provides.hostname
      den.provides.inputs'
      # WM home-manager configs for every user — keybinds/settings for each session.
      # The system half (compositor + session entry) is den.aspects.wm-sessions on the
      # host side; each WM file contributes to both collectors.
      den.aspects.wm-configs
      trustedUsers
    ];
  };

  # Enable mutual-provider at the user context so provides.to-users /
  # provides.to-hosts routing works across host <-> user boundaries.
  den.schema.user.includes = [ den.provides.mutual-provider ];
}
