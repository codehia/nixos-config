# Global defaults — config applied to every host and user.
# den.default sets baseline NixOS and home-manager options across all hosts.
{ den, ... }:
let
  trustedUsers = { user, ... }: { nixos.nix.settings.trusted-users = [ user.userName ]; };
in
{
  den.default = {
    nixos = {
      system.stateVersion = "26.05";
      time.timeZone = "Asia/Kolkata";
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocales = [ "all" ];
      };
    };
    homeManager.home.stateVersion = "26.05";
    includes = [
      den.batteries.define-user
      den.batteries.hostname
      den.batteries.inputs'
      trustedUsers
    ];
  };

  # WM home-manager configs for every user — keybinds/settings for each session.
  # homeManager only, so it goes on the user kind (den.default is walked at host scope too).
  # The system half (compositor + session entry) is den.aspects.wm-sessions on the
  # host side; each WM file contributes to both collectors.
  den.schema.user.includes = [ den.aspects.wm-configs ];
}
