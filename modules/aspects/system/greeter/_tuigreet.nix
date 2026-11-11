# Parked: tuigreet as greetd's default_session (the greeter after logout).
# Not loaded — the `_` prefix keeps import-tree away; dms-greeter (dms.nix) is the greeter.
# To use it: rename to tuigreet.nix, run `just write-flake` (adds the input back),
# include den.aspects.tuigreet in graphical-session and drop programs.dms-greeter.
# It lists every session that the WM modules register via
# services.displayManager.sessionPackages.
{
  flake-file.inputs.tuigreet = {
    # Pinned: later commits break Nix's fromTOML (TOML 1.1 Cargo.toml).
    url = "github:tuigreet/tuigreet/bd1078844cf2a98ccf82eb66dcdae3170dbe2e17";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.tuigreet.nixos =
    { inputs', config, ... }:
    let
      tuigreet = "${inputs'.tuigreet.packages.default}/bin/tuigreet";
      # Aggregated session entries from all WMs (sway, hyprland, mango, …).
      sessionsDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
    in
    {
      # /var/cache/tuigreet is required by --remember and --remember-user-session flags.
      systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0750 greeter greeter -" ];

      services.greetd.settings.default_session = {
        # No --theme: tuigreet's defaults render on the VT 16-slot palette, which
        # catppuccin.tty (appearance.nix) remaps to Mocha.
        command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --sessions ${sessionsDir}";
        user = "greeter";
      };
    };
}
