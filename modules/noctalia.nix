# Noctalia shell — all-in-one Wayland shell built on Quickshell.
# Replaces waybar, notifications, lock screen, wallpaper, OSD.
{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.noctalia = username: {
    nixos = {...}: {
      imports = [inputs.noctalia.nixosModules.default];
      services.noctalia-shell = {
        enable = true;
        target = "mango-session.target";
      };
    };

    homeManager = {...}: {
      imports = [inputs.noctalia.homeModules.default];
      programs.noctalia-shell = {
        enable = true;
        package = null; # package managed by NixOS module — avoid IPC conflicts
        settings = {
          # Weather & location
          location = {
            name = "Bangalore";
            weatherEnabled = true;
            useFahrenheit = false;
            showCalendarWeather = true;
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
            pinnedApps = [];
          };
        };
      };
    };
  };
}
