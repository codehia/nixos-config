# Greeter aspect: tuigreet-backed greetd session manager.
# Hosts set settings.greetd.{user,session}. initial_session auto-logs `user` into
# `session` (a binary name in /run/current-system/sw/bin, or an absolute command);
# after logout, tuigreet lists every session that the WM modules register via
# services.displayManager.sessionPackages.
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
      nixos =
        {
          inputs',
          config,
          lib,
          ...
        }:
        let
          tuigreet = "${inputs'.tuigreet.packages.default}/bin/tuigreet";
          # Aggregated session entries from all WMs (sway, hyprland, mango, …).
          sessionsDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        in
        {
          # /var/cache/tuigreet is required by --remember and --remember-user-session flags.
          systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0750 greeter greeter -" ];

          services.greetd = {
            enable = true;
            settings = {
              initial_session = {
                command = session;
                inherit user;
              };
              default_session = {
                # No --theme: tuigreet's defaults render on the VT 16-slot palette, which
                # catppuccin.tty (appearance.nix) remaps to Mocha.
                # Fallback only: dms-greeter (dms.nix) sets this with mkDefault and wins.
                command = lib.mkOptionDefault "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --sessions ${sessionsDir}";
                user = "greeter";
              };
            };
          };
        };
    };
in
{
  flake-file.inputs.tuigreet = {
    # Pinned: later commits break Nix's fromTOML (TOML 1.1 Cargo.toml).
    url = "github:tuigreet/tuigreet/bd1078844cf2a98ccf82eb66dcdae3170dbe2e17";
    inputs.nixpkgs.follows = "nixpkgs";
  };
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
