# Noctalia shell — all-in-one Wayland shell built on Quickshell.
# Replaces waybar, notifications, lock screen, wallpaper, OSD.
{ inputs, ... }:
{
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.noctalia = username: {
    nixos =
      { ... }:
      {
        imports = [ inputs.noctalia.nixosModules.default ];
        services.noctalia-shell = {
          enable = true;
          target = "mango-session.target";
        };
      };

    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.noctalia.homeModules.default ];

        # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
        # rsync --checksum compares file contents (not timestamps) and only
        # transfers files that actually differ. --delete removes extras.
        home.activation.syncWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          wallpaperSrc="/home/${username}/nixos-config/assets/.wallpapers"
          wallpaperDst="$HOME/Pictures/Wallpapers"

          if [ -d "$wallpaperSrc" ] && [ -n "$(ls -A "$wallpaperSrc" 2>/dev/null)" ]; then
            $DRY_RUN_CMD mkdir -p "$wallpaperDst"
            $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --checksum --delete "$wallpaperSrc/" "$wallpaperDst/"
          fi
        '';

        programs.noctalia-shell = {
          enable = true;
          package = null; # package managed by NixOS module — avoid IPC conflicts
          settings = {
            # Bar widgets — must be explicit when settings are declared
            bar.widgets = {
              left = [
                {
                  icon = "snowflake";
                  id = "Launcher";
                }
                {
                  id = "Workspace";
                  hideUnoccupied = false;
                }
                { id = "ActiveWindow"; }
              ];
              center = [
                {
                  id = "Clock";
                  formatHorizontal = "h:mm AP | ddd - MMM dd";
                  tooltipFormat = "h:mm AP | ddd - MMM dd";
                }
              ];
              right = [
                { id = "Tray"; }
                { id = "NotificationHistory"; }
                {
                  id = "Battery";
                  displayMode = "icon-hover";
                }
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "Volume"; }
                { id = "Brightness"; }
                { id = "ControlCenter"; }
              ];
            };

            # Weather & location
            location = {
              name = "Bangalore";
              weatherEnabled = true;
              useFahrenheit = false;
              showCalendarWeather = true;
              use12hourFormat = true;
            };

            # Night light — auto sunrise/sunset based on location
            nightLight = {
              enabled = true;
              autoSchedule = true;
              nightTemp = "3500";
              dayTemp = "6500";
            };

            # Notifications — top right, default density & durations
            notifications = {
              enabled = true;
              location = "top_right";
            };

            # Calendar — all cards enabled (header, month, weather)
            calendar.cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];

            # Wallpaper — local directory, 5min rotation, fade transition
            wallpaper = {
              enabled = true;
              directory = "/home/${username}/Pictures/Wallpapers";
              automationEnabled = true;
              wallpaperChangeMode = "random";
              randomIntervalSec = 300;
              transitionType = "fade";
              fillMode = "fit";
            };

            # Control Center — all cards enabled, brightness on
            controlCenter.cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = true;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];

            # Dock — auto-hide, attached to edge, colorized icons
            dock = {
              enabled = true;
              displayMode = "auto_hide";
              dockType = "attached";
              colorizeIcons = true;
              onlySameOutput = false;
              pinnedApps = [ ];
            };
          };
        };
      };
  };
}
