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
          programs = {
            hyprland = {
              enable = true;
              withUWSM = true;
              # nixpkgs-unstable release: cache.nixos.org, no separate hyprland nixpkgs copy
              package = pkgs.unstable.hyprland;
              portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
            };
            # unstable hyprland's hyprland-uwsm.desktop points at unstable uwsm; match it (one uwsm)
            uwsm.package = pkgs.unstable.uwsm;
          };
          # uwsm prints its startup steps on the VT at every login; 1 hides them, warnings stay (man uwsm)
          environment.sessionVariables.UWSM_SILENT_START = "1";
          # Backport of nixpkgs #532275 (not in 26.05): a switch that restarts these ends the uwsm session.
          # Drop when the system moves to 26.11.
          systemd.user.services = {
            "wayland-wm@" = {
              restartIfChanged = false;
              enableDefaultPath = false;
            };
            "wayland-session-bindpid@" = {
              restartIfChanged = false;
              enableDefaultPath = false;
            };
          };
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
