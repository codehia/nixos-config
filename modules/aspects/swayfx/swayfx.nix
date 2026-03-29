# SwayFX compositor — Sway fork with visual effects (blur, shadows, rounded corners).
# Uses the collector pattern: other files (binds.nix, input.nix, appearance.nix, scratchpad.nix)
# also define den.aspects.swayfx and their attrs are merged together by den.
#
# To activate: add den.aspects.swayfx to thinkpad.nix includes and set greetd session to "sway".
{
  den.aspects.swayfx = {
    nixos =
      { pkgs, ... }:
      {
        programs.sway = {
          enable = true;
          package = pkgs.swayfx;
        };
        environment.etc."wayland-sessions/sway.desktop".text = ''
          [Desktop Entry]
          Name=SwayFX
          Comment=An i3-compatible Wayland compositor with visual effects
          Exec=sway
          Type=Application
        '';

        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-wlr
            pkgs.xdg-desktop-portal-gtk
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        services.swayidle = {
          enable = true;
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
            grim
            slurp
            swappy
            swayr
          ];
          sessionVariables.NIXOS_OZONE_WL = "1";
        };

        wayland.windowManager.sway = {
          enable = true;
          package = pkgs.swayfx;
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
            ];

            output."*" = {
              scale = "1";
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
