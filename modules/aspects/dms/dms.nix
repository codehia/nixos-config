# DankMaterialShell — all-in-one Wayland shell built on Quickshell & Go.
# Replaces waybar, notifications, lock screen, launcher, OSD, clipboard, system monitor.
#
# isLaptop is a freeform host attribute (set in hosts.nix) — read via perHost.
# Usage: den.aspects.dms  (no args needed)
{ inputs, den, ... }:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den.aspects.dms = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.dms.nixosModules.dank-material-shell ];
        programs.dank-material-shell = {
          enable = true;
          dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
        # DMS enables power-profiles-daemon by default, which conflicts with TLP.
        services.power-profiles-daemon.enable = false;
      };

    includes = [
      (den.lib.perHost (
        { host }:
        let
          isLaptop = host.isLaptop or false;
          baseSettings = builtins.fromJSON (builtins.readFile ./dms-settings.json);
          # Filter battery widget from bar configs when not a laptop.
          patchBarConfig =
            bar:
            bar
            // {
              rightWidgets = builtins.filter (
                w:
                let
                  id = if builtins.isAttrs w then w.id else w;
                in
                isLaptop || id != "battery"
              ) bar.rightWidgets;
            };
          settings = baseSettings // {
            showBattery = isLaptop;
            osdPowerProfileEnabled = false;
            barConfigs = map patchBarConfig baseSettings.barConfigs;
          };
        in
        {
          homeManager =
            {
              lib,
              pkgs,
              config,
              ...
            }:
            {
              imports = [ inputs.dms.homeModules.dank-material-shell ];

              home.file.".config/DankMaterialShell/settings.json".text = builtins.toJSON settings;

              # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
              home.activation.syncWallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                wallpaperSrc="${config.home.homeDirectory}/nixos-config/assets/.wallpapers"
                wallpaperDst="$HOME/Pictures/Wallpapers"

                if [ -d "$wallpaperSrc" ] && [ -n "$(ls -A "$wallpaperSrc" 2>/dev/null)" ]; then
                  $DRY_RUN_CMD mkdir -p "$wallpaperDst"
                  $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a --checksum --delete "$wallpaperSrc/" "$wallpaperDst/"
                fi
              '';

              programs.dank-material-shell = {
                enable = true;
                dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
                enableSystemMonitoring = true;
                enableVPN = true;
                enableDynamicTheming = false;
                enableAudioWavelength = false;
                enableCalendarEvents = false;
                systemd = {
                  enable = true;
                  restartIfChanged = true;
                };
              };

              # qt5ct/qt6ct config requests kvantum as the Qt style, but kvantum fails
              # to load due to a qtsvg version mismatch, causing quickshell to deadlock.
              # Bypass qt5ct entirely for DMS — it uses its own QML theme anyway.
              systemd.user.services.dms = {
                Service.Environment = "QT_QPA_PLATFORMTHEME=gtk3";
              };
            };
        }
      ))
    ];
  };
}
