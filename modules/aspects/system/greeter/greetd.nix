# Greeter aspect: greetd session manager.
# Hosts set settings.greetd.{user,session}. initial_session auto-logs `user` into
# `session` (a binary name in /run/current-system/sw/bin, or an absolute command).
{ lib, ... }:
let
  greetdConfig =
    { host }:
    let
      inherit (host.settings.greetd) user;
      session =
        if lib.hasPrefix "/" host.settings.greetd.session then
          host.settings.greetd.session
        else
          "/run/current-system/sw/bin/${host.settings.greetd.session}";
    in
    {
      # default_session (the greeter after logout) comes from dms-greeter (dms.nix);
      # the tuigreet alternative is parked in _tuigreet.nix.
      nixos.services.greetd = {
        enable = true;
        # Autologin on boot.
        settings.initial_session = {
          command = session;
          inherit user;
        };
      };
    };
in
{
  den.aspects.greetd = {
    settings = {
      user = lib.mkOption {
        type = lib.types.str;
        description = "User greetd auto-logs into on boot.";
      };
      session = lib.mkOption {
        type = lib.types.str;
        description = "Auto-login session: a binary in /run/current-system/sw/bin, or an absolute command.";
      };
    };

    includes = [ greetdConfig ];
  };
}
