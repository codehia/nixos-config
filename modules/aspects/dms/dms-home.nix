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
          catppuccinTheme = {
            dark = {
              name = "Catppuccin Mocha";
              primary = "#cba6f7"; # Mauve
              primaryText = "#1e1e2e"; # Base
              primaryContainer = "#89b4fa"; # Blue
              secondary = "#f9e2af"; # Yellow
              surface = "#1e1e2e"; # Base (one level above Mantle background)
              surfaceText = "#cdd6f4"; # Text
              surfaceVariant = "#313244"; # Surface0
              surfaceVariantText = "#cdd6f4"; # Text
              surfaceTint = "#cba6f7"; # Mauve
              background = "#181825"; # Mantle
              backgroundText = "#cdd6f4"; # Text
              outline = "#6c7086"; # Overlay0
              surfaceContainer = "#313244"; # Surface0
              surfaceContainerHigh = "#45475a"; # Surface1
              error = "#f38ba8"; # Red
              warning = "#f9e2af"; # Yellow
              info = "#94e2d5"; # Teal
            };
            light = {
              name = "Catppuccin Latte";
              primary = "#8839ef"; # Mauve
              primaryText = "#eff1f5"; # Base
              primaryContainer = "#1e66f5"; # Blue
              secondary = "#df8e1d"; # Yellow
              surface = "#e6e9ef"; # Mantle
              surfaceText = "#4c4f69"; # Text
              surfaceVariant = "#ccd0da"; # Surface0
              surfaceVariantText = "#4c4f69"; # Text
              surfaceTint = "#8839ef"; # Mauve
              background = "#eff1f5"; # Base
              backgroundText = "#4c4f69"; # Text
              outline = "#acb0be"; # Surface2
              surfaceContainer = "#ccd0da"; # Surface0
              surfaceContainerHigh = "#bcc0cc"; # Surface1
              error = "#d20f39"; # Red
              warning = "#df8e1d"; # Yellow
              info = "#179299"; # Teal
            };
          };
          themeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/catppuccin-mocha.json";
          finalSettings = lib.recursiveUpdate settings {
            customThemeFile = themeFile;
            currentThemeName = "custom"; # DMS Theme.qml only loads customThemeFile when name === "custom"
            currentThemeCategory = "custom";
          };
        in
        {
          imports = [ inputs.dms.homeModules.dank-material-shell ];

          home.file.".config/DankMaterialShell/catppuccin-mocha.json".text = builtins.toJSON catppuccinTheme;

          # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
          home.activation.syncWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            wallpaperSrc="${self}/assets/.wallpapers"
            wallpaperDst="$HOME/Pictures/Wallpapers"

            if [ -d "$wallpaperSrc" ] && [ -n "$(ls -A "$wallpaperSrc" 2>/dev/null)" ]; then
              $DRY_RUN_CMD mkdir -p "$wallpaperDst"
              $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --checksum --delete "$wallpaperSrc/" "$wallpaperDst/"
            fi
          '';

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
            systemd = {
              enable = true;
              restartIfChanged = true;
            };
          };

          # qt5ct/qt6ct config requests kvantum as the Qt style, but kvantum fails
          # to load due to a qtsvg version mismatch, causing quickshell to deadlock.
          # Bypass qt5ct entirely for DMS — it uses its own QML theme anyway.
          systemd.user.services.dms.Service.Environment = "QT_QPA_PLATFORMTHEME=gtk3";
        };
    }
  );
in
{
  den.aspects.dms-home = {
    includes = [ dmsPerUser ];
  };
}
