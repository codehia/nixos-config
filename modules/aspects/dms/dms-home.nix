# DankMaterialShell — per-user HM config.
# Lives in user includes (deus, soumya). Parametric on host.isLaptop for bar/battery config.
{
  inputs,
  den,
  lib,
  self,
  ...
}:
let
  # dms-settings.json has runningAppsCurrentWorkspace = false.
  # Hyprland special workspaces (pyprland scratchpads) have negative workspace IDs, so they
  # never match the current regular workspace and would be permanently hidden from the running
  # apps list if this were true.
  baseSettings = builtins.fromJSON (builtins.readFile ./dms-settings.json);

  dmsPerUser = den.lib.perUser (
    { host, ... }:
    let
      isLaptop = host.isLaptop or false;
      patchBarConfig =
        bar:
        lib.recursiveUpdate bar {
          rightWidgets = builtins.filter (
            w:
            let
              id = if builtins.isAttrs w then w.id else w;
            in
            isLaptop || id != "battery"
          ) bar.rightWidgets;
        };
      settings = lib.recursiveUpdate baseSettings {
        showBattery = isLaptop;
        osdPowerProfileEnabled = false;
        barConfigs = map patchBarConfig baseSettings.barConfigs;

        # Disable matugen — not installed (enableDynamicTheming = false).
        runUserMatugenTemplates = false;
        runDmsMatugenTemplates = false;
        matugenTemplateGtk = false;
        matugenTemplateNiri = false;
        matugenTemplateHyprland = false;
        matugenTemplateMangowc = false;
        matugenTemplateQt5ct = false;
        matugenTemplateQt6ct = false;
        matugenTemplateFirefox = false;
        matugenTemplatePywalfox = false;
        matugenTemplateZenBrowser = false;
        matugenTemplateVesktop = false;
        matugenTemplateEquibop = false;
        matugenTemplateGhostty = false;
        matugenTemplateKitty = false;
        matugenTemplateFoot = false;
        matugenTemplateAlacritty = false;
        matugenTemplateNeovim = false;
        matugenTemplateWezterm = false;
        matugenTemplateDgop = false;
        matugenTemplateKcolorscheme = false;
        matugenTemplateVscode = false;
        matugenTemplateEmacs = false;

        # Disable audio visualizer — cava not installed (enableAudioWavelength = false).
        audioVisualizerEnabled = false;

        # Lock session before suspend/hibernate.
        lockBeforeSuspend = true;
      };
    in
    {
      homeManager =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        let
          home = config.home.homeDirectory;

          batteryToggleScript = lib.optionalString isLaptop (
            toString (
              pkgs.writeShellScript "battery-charge-user-toggle" ''
                current=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo 100)
                if [ "$current" -le 80 ]; then
                  sudo ${pkgs.tlp}/bin/tlp setcharge BAT0 95 100
                  ${pkgs.libnotify}/bin/notify-send -u normal "Battery" "Full charge (100%)"
                else
                  sudo ${pkgs.tlp}/bin/tlp setcharge BAT0 75 80
                  ${pkgs.libnotify}/bin/notify-send -u normal "Battery" "Health mode (80%)"
                fi
              ''
            )
          );

          # Detects max connected-display width via kernel DRM sysfs (no Wayland or DMS required),
          # populates ~/Pictures/Wallpapers/active/ with symlinks from the right resolution folder.
          # Idempotent — safe to re-trigger on display hotplug (e.g. from Kanshi).
          wallpaperSelectScript = pkgs.writeShellScript "dms-wallpaper-select" ''
            WALLPAPER_BASE="$HOME/Pictures/Wallpapers"
            ACTIVE_DIR="$WALLPAPER_BASE/active"

            # Widest single connected display (kernel DRM sysfs, not combined)
            WIDTH=$(
              for d in /sys/class/drm/card*-*/; do
                [ "$(cat "$d/status" 2>/dev/null)" = "connected" ] && cat "$d/modes" 2>/dev/null
              done | awk -Fx '{print $1}' | sort -n | tail -1
            )

            if [ "''${WIDTH:-0}" -ge 3440 ]; then
              FOLDER="$WALLPAPER_BASE/ultrawide"
            else
              FOLDER="$WALLPAPER_BASE/regular"
            fi

            # Ensure Wallpapers/ is writable (rsync from nix store can leave it 555)
            chmod u+w "$WALLPAPER_BASE" 2>/dev/null || true

            mkdir -p "$ACTIVE_DIR"
            find "$ACTIVE_DIR" -maxdepth 1 -type l -delete

            for f in "$FOLDER"/*; do
              [ -f "$f" ] || continue
              ln -sf "$f" "$ACTIVE_DIR/$(basename "$f")"
            done

            # Extension-less link as initial wallpaper — excluded from cycling by find's -iname patterns
            FIRST=$(ls "$FOLDER" 2>/dev/null | head -1)
            [ -n "$FIRST" ] && ln -sf "$FOLDER/$FIRST" "$ACTIVE_DIR/wallpaper" || true
          '';

          wallpaperSelectService = {
            Unit = {
              Description = "Select wallpaper folder based on monitor resolution";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${wallpaperSelectScript}";
              RemainAfterExit = true;
              Environment = "PATH=/run/current-system/sw/bin:${
                lib.makeBinPath [
                  pkgs.gawk
                  pkgs.findutils
                  pkgs.coreutils
                ]
              }";
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          finalSettings = lib.recursiveUpdate settings {
            customThemeFile = "${home}/.config/DankMaterialShell/themes/catppuccin/theme.json";
            currentThemeName = "custom"; # DMS Theme.qml only loads customThemeFile when name === "custom"
            currentThemeCategory = "custom";
          };
        in
        {
          imports = [ inputs.dms.homeModules.dank-material-shell ];

          home.file.".config/DankMaterialShell/themes/catppuccin/theme.json".source = ./catppuccin-theme.json;
          home.file.".face".source = "${self}/assets/profile.jpg";

          # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
          home.activation.syncWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            wallpaperSrc="${self}/assets/.wallpapers"
            wallpaperDst="$HOME/Pictures/Wallpapers"

            if [ -d "$wallpaperSrc" ] && [ -n "$(ls -A "$wallpaperSrc" 2>/dev/null)" ]; then
              $DRY_RUN_CMD mkdir -p "$wallpaperDst"
              $DRY_RUN_CMD chmod u+w "$wallpaperDst"
              $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --checksum --delete --no-perms --chmod=D755,F644 --exclude='active' "$wallpaperSrc/" "$wallpaperDst/"

              # Pre-populate active/ so DMS has a wallpaper even before the service runs.
              # Same DRM detection as the service — widest single connected display.
              WIDTH=$(
                for d in /sys/class/drm/card*-*/; do
                  [ "$(cat "$d/status" 2>/dev/null)" = "connected" ] && cat "$d/modes" 2>/dev/null
                done | ${pkgs.gawk}/bin/awk -Fx '{print $1}' | sort -n | tail -1
              ) || true
              if [ "''${WIDTH:-0}" -ge 3440 ]; then
                folder="$wallpaperDst/ultrawide"
              else
                folder="$wallpaperDst/regular"
              fi
              mkdir -p "$wallpaperDst/active"
              find "$wallpaperDst/active" -maxdepth 1 -type l -delete
              for f in "$folder"/*; do
                [ -f "$f" ] || continue
                ln -sf "$f" "$wallpaperDst/active/$(basename "$f")"
              done
              FIRST=$(ls "$folder" 2>/dev/null | head -1) || true
              [ -n "$FIRST" ] && ln -sf "$folder/$FIRST" "$wallpaperDst/active/wallpaper" || true
            fi
          '';

          # force=true replaces the stale real directory (from a pre-nix manual DMS install)
          # with the nix-managed symlink. DMS only reads plugin dirs — state goes to
          # ~/.local/state/DankMaterialShell/plugins/ — so read-only nix store is fine.
          xdg.configFile."DankMaterialShell/plugins/dankPomodoroTimer".force = true;

          programs.dank-material-shell = {
            enable = true;
            dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
            quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
            enableSystemMonitoring = true;
            enableVPN = true;
            enableDynamicTheming = false;
            enableAudioWavelength = false;
            enableCalendarEvents = false;
            settings = finalSettings;
            session = {
              wallpaperPath = "${home}/Pictures/Wallpapers/active/wallpaper";
              wallpaperCyclingEnabled = true;
              wallpaperCyclingMode = "interval";
              wallpaperCyclingInterval = 300;
            };
            plugins.dankPomodoroTimer = {
              src =
                pkgs.fetchFromGitHub {
                  owner = "AvengeMedia";
                  repo = "dms-plugins";
                  rev = "141841fc85e01494df6d217bd5a27c65da87256d";
                  hash = "sha256-/155wFIotV9xiZzX9XRGs3ANjBcLJwS4kNDDNO6WkF0=";
                }
                + "/DankPomodoroTimer";
            };
            plugins.dankBatteryAlerts = lib.mkIf isLaptop {
              src =
                pkgs.fetchFromGitHub {
                  owner = "AvengeMedia";
                  repo = "dms-plugins";
                  rev = "a759ddfccb021ef7e6824685e7a1c3728170977e";
                  hash = "sha256-s6zQvPoTaJYMA8A/vUEgQhTE/VhQJZwcGw1ET6bOYKg=";
                }
                + "/DankBatteryAlerts";
              settings = {
                warningThreshold = 15;
              };
            };
            managePluginSettings = true;
            systemd = {
              enable = true;
              restartIfChanged = true;
            };
          };

          wayland.windowManager.sway.config.keybindings = lib.mkIf isLaptop (
            lib.mkOptionDefault { "Mod4+b" = "exec ${batteryToggleScript}"; }
          );

          wayland.windowManager.hyprland.settings.bind = lib.optionals isLaptop [
            "$modifier, B, exec, ${batteryToggleScript}"
          ];

          systemd.user.services.dms-wallpaper-select = wallpaperSelectService;

          systemd.user.services.dms = {
            # qt5ct/qt6ct config requests kvantum as the Qt style, but kvantum fails
            # to load due to a qtsvg version mismatch, causing quickshell to deadlock.
            # Bypass qt5ct entirely for DMS — it uses its own QML theme anyway.
            Service.Environment = "QT_QPA_PLATFORMTHEME=gtk3";
            # UWSM owns the session (hyprland.systemd.enable = false), so hyprland-session.target
            # is never created. Override to graphical-session.target which UWSM activates instead.
            Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
            # Wait for wallpaper selection before starting.
            Unit.After = [ "dms-wallpaper-select.service" ];
            Unit.Wants = [ "dms-wallpaper-select.service" ];
          };
        };
    }
  );
in
{
  den.aspects.dms-home = {
    includes = [ dmsPerUser ];
  };
}
