{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    swww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils # needed for banners and ANR messages
  ];
  systemd.user.targets.hyprland-session.Unit.Wants =
    [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    xwayland = { enable = true; };
    plugins = [ pkgs.pyprland ];
    settings = {
      exec-once = [
        "pypr &"
        "1password --silent &"
        "spotify &"
        "mullvad-gui &"
        "enteauth &"
      ];
      env = [ "HYPRCURSOR_THEME, MyCursor" "HYPRCURSOR_SIZE, 32" ];
      input = {
        kb_options = [ "grp:alt_caps_toggle" "caps:super" ];
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
        vfr = true; # Variable Frame Rate
        vrr =
          2; # Variable Refresh Rate  Might need to set to 0 for NVIDIA/AQ_DRM_DEVICES
        # Screen flashing to black momentarily or going black when app is fullscreen
        # Try setting vrr to 0

        #  Application not responding (ANR) settings
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
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = true;
        warp_on_change_workspace = 0;
        no_warps = true;
      };

      render = {
        # Disabling as no longer supported
        #explicit_sync = 1; # Change to 1 to disable
        #explicit_sync_kms = 1;
        direct_scanout = 0;
      };

      master = {
        orientation = "center";
        new_status = "master";
        mfact = 0.62;
        slave_count_for_center_master = 2;
      };
      workspace = [
        "1, persistent:true,"
        "2, persistent:true,"
        "3, persistent:true,"
        "4, persistent:true,"
        "5, persistent:true,"
        "special:minimized, gapsout:100"
      ];

      windowrulev2 = [
        # 1Password
        "float,           class:^(1Password)$"
        "size 30% 50%,    class:^(1Password)$"
        "move 100%-w-40 5%,     class:^(1Password)$"
        "workspace special:drop-1pw, class:^(1Password)$"

        # Spotify
        "float,           class:^(Spotify)$"
        "size 40% 60%,    class:^(Spotify)$"
        "move 100%-w-40 5%,     class:^(Spotify)$"
        "workspace special:drop-spotify, class:^(Spotify)$"

        # Ente (add ente-auth if you see it)
        "float,           class:^(io.ente.auth)$"
        "size 10% 80%,    class:^(io.ente.auth)$"
        "move 100%-w-40 5%,     class:^(io.ente.auth)$"
        "workspace special:drop-ente, class:^(io.ente.auth)$"

        # Slack
        "float,           class:^(Slack)$"
        "size 70% 70%,    class:^(Slack)$"
        "workspace special:drop-slack, class:^(Slack)$"
      ];
    };

    # ${extraMonitorSettings}
    extraConfig = "layerrule = blur,waybar";
  };
}
