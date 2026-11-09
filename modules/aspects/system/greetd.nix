# Greeter aspect: tuigreet-backed greetd session manager.
# greetdUser and greetdSessionBin are freeform host attributes (set in the host declarations).
# initial_session auto-logs greetdUser into /run/current-system/sw/bin/<greetdSessionBin>
# (override with host.greetdSessionCmd); after logout, tuigreet lists every session that
# the WM modules register via services.displayManager.sessionPackages.
let
  greetdConfig =
    { host }:
    let
      user = host.greetdUser;
      session = host.greetdSessionCmd or "/run/current-system/sw/bin/${host.greetdSessionBin}";
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
    includes = [ greetdConfig ];
  };
}
