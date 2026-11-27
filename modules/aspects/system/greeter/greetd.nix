# Greeter aspect: greetd session manager.
# Hosts set settings.greetd.{user,session}. initial_session auto-logs `user` into
# `session` (a command whose binary is in /run/current-system/sw/bin).
{ lib, ... }:
let
  greetdConfig =
    { host }:
    let
      inherit (host.settings.greetd) user;
      session = "/run/current-system/sw/bin/${host.settings.greetd.session}";
    in
    {
      # default_session (the greeter after logout) comes from dms-greeter (dms.nix).
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
        description = "Auto-login session: a command whose binary is in /run/current-system/sw/bin.";
      };
    };

    includes = [ greetdConfig ];
  };
}
