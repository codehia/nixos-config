# Hyprland compositor — base config, packages, and settings.
# Uses the collector pattern: other files (binds.nix, hyprpaper.nix, pyprland.nix) also define
# den.aspects.hyprland and their attrs are merged together by den.
{ inputs, ... }:
{
  flake-file.inputs.hyprland = {
    url = "github:hyprwm/hyprland";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.hyprland = {
    nixos = _: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
    };

    homeManager =
      { pkgs, ... }:
      {
        home.sessionVariables.NIXOS_OZONE_WL = "1";
        home.packages = with pkgs; [
          swww
          grim
          slurp
          wl-clipboard
          swappy
          ydotool
          hyprpolkitagent
          hyprland-qtutils
        ];
        systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
        wayland.windowManager.hyprland = {
          enable = true;
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          portalPackage =
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          systemd = {
            enable = true;
            enableXdgAutostart = true;
            variables = [ "--all" ];
          };
          xwayland.enable = true;
          plugins = [ pkgs.pyprland ];
          settings = {
            exec-once = [
              "pypr &"
              "1password --silent &"
              "spotify &"
              "mullvad-gui &"
              "enteauth &"
            ];
            env = [
              "HYPRCURSOR_THEME, MyCursor"
              "HYPRCURSOR_SIZE, 32"
              "XCURSOR_SIZE, 32"
            ];
            input = {
              kb_options = [
                "grp:alt_caps_toggle"
                "caps:super"
              ];
              numlock_by_default = false;
              repeat_delay = 300;
              follow_mouse = 0;
              float_switch_override_focus = 0;
              sensitivity = 0;
              touchpad = {
                natural_scroll = false;
                disable_while_typing = true;
                scroll_factor = 0.8;
              };
            };

            general = {
              "$mod" = "SUPER";
              layout = "master";
              gaps_in = 5;
              gaps_out = 7;
              border_size = 4;
              resize_on_border = true;
              "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
              "col.inactive_border" = "rgba(595959aa)";
            };

            misc = {
              layers_hog_keyboard_focus = true;
              initial_workspace_tracking = 1;
              mouse_move_enables_dpms = true;
              key_press_enables_dpms = false;
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              enable_swallow = true;
              vfr = true;
              vrr = 2;
              enable_anr_dialog = true;
              anr_missed_pings = 15;
            };

            decoration = {
              rounding = 7;
              rounding_power = 4.0;
              blur = {
                enabled = true;
                size = 5;
                passes = 3;
                ignore_opacity = false;
                new_optimizations = true;
              };
              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
              };
            };

            ecosystem = {
              no_donation_nag = true;
              no_update_news = true;
            };

            cursor = {
              sync_gsettings_theme = true;
              no_hardware_cursors = 2;
              enable_hyprcursor = true;
              warp_on_change_workspace = 0;
              no_warps = true;
            };

            render = {
              direct_scanout = 0;
            };

            master = {
              orientation = "center";
              new_status = "master";
              mfact = 0.62;
              slave_count_for_center_master = 2;
            };

            monitor = [ ", preferred, auto, 1" ];

            workspace = [
              "1, persistent:true,"
              "2, persistent:true,"
              "3, persistent:true,"
              "4, persistent:true,"
              "5, persistent:true,"
              "special:minimized, gapsout:100"
            ];
          };
        };
      };
  };
}
