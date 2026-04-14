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
          themeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/catppuccin/theme.json";
          finalSettings = lib.recursiveUpdate settings {
            customThemeFile = themeFile;
            currentThemeName = "custom"; # DMS Theme.qml only loads customThemeFile when name === "custom"
            currentThemeCategory = "custom";
          };
        in
        {
          imports = [ inputs.dms.homeModules.dank-material-shell ];

          home.file.".config/DankMaterialShell/themes/catppuccin/theme.json".source = ./catppuccin-theme.json;

          home.file.".face".source = "${self}/assets/profile.jpg";

          # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
          # Also seeds session.json wallpaperPath on first install (only if file absent).
          # Note: session.json is owned by DMS at runtime — we must NOT use the HM
          # session option which would replace it with a read-only nix store symlink.
          home.activation.syncWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            wallpaperSrc="${self}/assets/.wallpapers"
            wallpaperDst="$HOME/Pictures/Wallpapers"

            if [ -d "$wallpaperSrc" ] && [ -n "$(ls -A "$wallpaperSrc" 2>/dev/null)" ]; then
              $DRY_RUN_CMD mkdir -p "$wallpaperDst"
              $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --checksum --delete "$wallpaperSrc/" "$wallpaperDst/"
            fi

            sessionFile="$HOME/.local/state/DankMaterialShell/session.json"
            defaultWallpaper="$HOME/Pictures/Wallpapers/ultrawide/hello-world-pixel-3440x1440-15168.png"
            if [ -z "$DRY_RUN_CMD" ] && [ ! -f "$sessionFile" ]; then
              mkdir -p "$(dirname "$sessionFile")"
              echo "{\"wallpaperPath\":\"$defaultWallpaper\"}" > "$sessionFile"
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
            managePluginSettings = true;
            systemd = {
              enable = true;
              restartIfChanged = true;
            };
          };

          systemd.user.services.dms = {
            # qt5ct/qt6ct config requests kvantum as the Qt style, but kvantum fails
            # to load due to a qtsvg version mismatch, causing quickshell to deadlock.
            # Bypass qt5ct entirely for DMS — it uses its own QML theme anyway.
            Service.Environment = "QT_QPA_PLATFORMTHEME=gtk3";
            # UWSM owns the session (hyprland.systemd.enable = false), so hyprland-session.target
            # is never created. Override to graphical-session.target which UWSM activates instead.
            Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
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
