# Hyprland compositor — base config, packages, and settings.
# Uses the collector pattern: hypridle.nix also defines
# den.aspects.hyprland and their attrs are merged together by den.
#
# The compositor itself is system-level: the nixos block lives in den.aspects.wm-sessions
# (a collector shared by all WM aspects, included by graphical-session) so the session
# registers with services.displayManager.sessionPackages and appears in the greeter.
{ den, ... }:
{
  den.aspects = {
    wm-configs.includes = [ den.aspects.hyprland ];

    wm-sessions = {
      nixos =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          inherit (config.programs) hyprland uwsm;
          # Greeter entries: the package ships hyprland.desktop (bare start-hyprland, no
          # UWSM -> no graphical-session.target, DMS never starts) and
          # hyprland-uwsm.desktop ("Hyprland (uwsm-managed)"). Hide the bare one and
          # name the UWSM one "Hyprland". uwsm refuses Hidden entries, so the UWSM entry
          # starts start-hyprland by path instead of via hyprland.desktop.
          # mkBefore: first package wins in the session dir (lndir keeps existing links),
          # and that dir precedes /run/current-system/sw/share in XDG_DATA_DIRS.
          hyprlandSessions =
            pkgs.runCommand "hyprland-sessions" { passthru.providedSessions = [ "hyprland-uwsm" ]; }
              ''
                d=$out/share/wayland-sessions
                mkdir -p $d
                { cat ${hyprland.package}/share/wayland-sessions/hyprland.desktop; echo Hidden=true; } > $d/hyprland.desktop
                cat > $d/hyprland-uwsm.desktop <<EOF
                [Desktop Entry]
                Name=Hyprland
                Comment=An intelligent dynamic tiling Wayland compositor
                Exec=${uwsm.package}/bin/uwsm start -F -e -D Hyprland -N Hyprland -- ${hyprland.package}/bin/start-hyprland
                TryExec=${uwsm.package}/bin/uwsm
                DesktopNames=Hyprland
                Type=Application
                EOF
              '';
        in
        {
          services.displayManager.sessionPackages = lib.mkBefore [ hyprlandSessions ];
          programs.hyprland = {
            enable = true;
            withUWSM = true;
            # nixpkgs-unstable release: cache.nixos.org, no separate hyprland nixpkgs copy
            package = pkgs.unstable.hyprland;
            portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
          };
          # unstable hyprland's hyprland-uwsm.desktop points at unstable uwsm; match it (one uwsm)
          programs.uwsm.package = pkgs.unstable.uwsm;
        };
    };

    hyprland = {
      homeManager =
        {
          config,
          osConfig,
          pkgs,
          ...
        }:
        {
          # Export HM session variables into the UWSM environment so systemd
          # services (DMS, etc.) inherit PATH and other HM-set vars.
          # The guard must be unset first: it is already =1 in the login chain's
          # environment, so sourcing alone is a no-op and nothing (NIXOS_OZONE_WL
          # included) reaches the systemd activation environment — DMS-launched
          # Electron apps then silently fall back to XWayland.
          xdg.configFile = {
            "uwsm/env".text = ''
              unset __HM_SESS_VARS_SOURCED
              . ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
            '';
            # Hyprland 0.57 reads only hyprland.lua (Lua config); hand-written, see hyprland.lua.
            "hypr/hyprland.lua".source = ./hyprland.lua;
            # Overview plugin; stable path so the static Lua can hl.plugin.load() it.
            # pkgs.unstable: built against the same pkgs.unstable.hyprland the session runs.
            # src bumped: nixpkgs' 12d1c68 doesn't compile on 0.57; upstream fixed it in
            # 04d2365 (2026-11-09). Drop the override once nixpkgs packages it (local build).
            "hypr/plugins/hyprtasking.so".source = "${
              pkgs.unstable.hyprlandPlugins.hyprtasking.overrideAttrs {
                version = "0-unstable-2026-11-09";
                src = pkgs.fetchFromGitHub {
                  owner = "raybbian";
                  repo = "hyprtasking";
                  rev = "04d2365d37f032af537b8d5c55efbfe15f01adc7";
                  hash = "sha256-KzxmA0lqTvZKq/AHdSu2juugkfXwLC6ywR4BeAfiIIg=";
                };
              }
            }/lib/libhyprtasking.so";
          };
          home.packages = with pkgs; [
            # nixpkgs grimblast depends on nixpkgs hyprland (a 2nd Hyprland); use the session's.
            (grimblast.override { hyprland = osConfig.programs.hyprland.package; })
            satty
            wl-clipboard
          ];
        };
    };
  };
}
