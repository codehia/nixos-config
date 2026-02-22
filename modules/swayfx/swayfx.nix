# SwayFX compositor — Sway fork with visual effects (blur, shadows, rounded corners).
# Uses the collector pattern: other files (binds.nix, input.nix, appearance.nix, scratchpad.nix)
# also define den.aspects.swayfx and their attrs are merged together by den.
#
# To activate: add den.aspects.swayfx to thinkpad.nix includes and set greetd session to "sway".
{...}: {
  den.aspects.swayfx = {
    nixos = {pkgs, ...}: {
      programs.sway = {
        enable = true;
        package = pkgs.swayfx;
      };

      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk];
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        wl-clipboard
        grim
        slurp
        swappy
        swayr
        autotiling-rs
      ];

      home.sessionVariables.NIXOS_OZONE_WL = "1";

      wayland.windowManager.sway = {
        enable = true;
        package = pkgs.swayfx;
        checkConfig = false;
        systemd = {
          enable = true;
          xdgAutostart = true;
          variables = ["--all"];
        };
        xwayland = true;
        wrapperFeatures.gtk = true;

        config = {
          modifier = "Mod4";
          terminal = "ghostty";
          menu = "rofi -show drun";
          defaultWorkspace = "workspace number 1";

          output."*" = {
            scale = "1";
          };

          gaps = {
            inner = 7;
            outer = 0;
          };

          floating.modifier = "Mod4";

          startup = [
            {command = "autotiling-rs";}
            {command = "1password --silent";}
            {command = "spotify --minimized";}
            {command = "enteauth";}
          ];

          bars = [];

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

          seat."*" = {
            xcursor_theme = "default 32";
          };
        };
      };
    };
  };
}
