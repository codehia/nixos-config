# SwayFX compositor — Sway fork with visual effects (blur, shadows, rounded corners).
# Uses the collector pattern: other files (binds.nix, appearance.nix, layouts.nix, scratchpad.nix)
# also define den.aspects.swayfx and their attrs are merged together by den.
#
# The compositor itself is system-level: the nixos block lives in den.aspects.wm-sessions
# (a collector shared by all WM aspects, included by graphical-session) so the session
# registers with services.displayManager.sessionPackages and appears in the greeter.
# The HM config half reaches every user via the den.aspects.wm-configs collector (den.default).
{ den, ... }:
{
  den.aspects.wm-configs.includes = [ den.aspects.swayfx ];

  den.aspects.wm-sessions = {
    nixos =
      { pkgs, ... }:
      {
        programs.sway = {
          enable = true;
          package = pkgs.swayfx;
        };

        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-wlr
            pkgs.xdg-desktop-portal-gtk
          ];
        };
      };
  };

  den.aspects.swayfx = {
    homeManager =
      { pkgs, ... }:
      {
        # Bound to sway-session.target, not graphical-session.target — Hyprland brings its
        # own polkit agent, and this must not start under other compositors.
        systemd.user.services.lxqt-policykit-agent = {
          Unit = {
            Description = "LXQt PolicyKit Authentication Agent";
            After = [ "sway-session.target" ];
            PartOf = [ "sway-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "sway-session.target" ];
        };

        services.swayidle = {
          enable = true;
          # Bind to the sway session only — with all WMs' HM configs active per user,
          # graphical-session.target would start this under every compositor.
          systemdTargets = [ "sway-session.target" ];
          events = [
            {
              event = "before-sleep";
              command = "${pkgs.playerctl}/bin/playerctl -a pause";
            }
            {
              event = "lock";
              command = "${pkgs.playerctl}/bin/playerctl -a pause";
            }
          ];
        };

        home = {
          packages = with pkgs; [
            playerctl
            wl-clipboard
            sway-contrib.grimshot
            satty
            swayr
          ];
          sessionVariables.NIXOS_OZONE_WL = "1";
        };

        wayland.windowManager.sway = {
          enable = true;
          # Binary comes from the system (programs.sway in wm-sessions) — null avoids
          # installing a second copy in the user profile.
          package = null;
          checkConfig = false;
          xwayland = true;
          wrapperFeatures.gtk = true;
          systemd = {
            enable = true;
            xdgAutostart = true;
            variables = [ "--all" ];
          };

          config = {
            modifier = "Mod4";
            floating.modifier = "Mod4";
            terminal = "ghostty";
            menu = "rofi -show drun";
            defaultWorkspace = "workspace number 1";

            startup = [
              { command = "1password --silent"; }
              { command = "spotify --minimized"; }
              { command = "enteauth"; }
              # swayrd tracks window focus history — required by the swayr
              # focus-last/urgent binds (Mod+x / Mod+u) in binds.nix.
              { command = "swayrd"; }
            ];

            output."*" = {
              scale = "1";
            };

            output."HDMI-A-1" = {
              mode = "3440x1440@75.050Hz";
            };

            gaps = {
              inner = 7;
              outer = 0;
            };

            bars = [ ];

            window = {
              titlebar = false;
              border = 4;
              hideEdgeBorders = "none";
            };

            floating = {
              titlebar = false;
              border = 4;
            };

            focus = {
              followMouse = "no";
              wrapping = "yes";
            };
          };
        };
      };
  };
}
