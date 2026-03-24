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
      };
    in
    {
      homeManager =
        {
          pkgs,
          lib,
          ...
        }:
        {
          imports = [ inputs.dms.homeModules.dank-material-shell ];

          # home.file.".config/DankMaterialShell/settings.json".text = builtins.toJSON settings;
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
            settings = settings;
            systemd = {
              enable = true;
              restartIfChanged = true;
            };
          };
          # home.file.".config/DankMaterialShell/settings.json".text = builtins.toJSON settings;

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
