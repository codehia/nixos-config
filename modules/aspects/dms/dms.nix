# DankMaterialShell — all-in-one Wayland shell built on Quickshell & Go.
# Replaces waybar, notifications, lock screen, launcher, OSD, clipboard, system monitor.
#
# isLaptop is a freeform host attribute (set in hosts.nix) — read via perHost.
# Usage: den.aspects.dms
{
  inputs,
  den,
  lib,
  self,
  ...
}:
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

    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.dms.homeModules.dank-material-shell ];

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

    # perUser, not perHost, is required here.
    # Den runs includes through a pipeline of context stages:
    #   perHost ({ host })     → ctx.host stage   — homeManager outputs are NOT forwarded.
    #   perUser ({ host, user }) → ctx.hm-user stage — homeManager outputs ARE forwarded.
    # The owned homeManager config above applies at ctx.hm-host (always forwarded).
    # This parametric include varies per host (isLaptop) and outputs homeManager config,
    # so it must use perUser to reach the ctx.hm-user stage where forwarding happens.
    includes = [
      (den.lib.perUser (
        { host, ... }:
        let
          isLaptop = host.isLaptop or false;
          baseSettings = builtins.fromJSON (builtins.readFile ./dms-settings.json);
          # Filter battery widget from bar configs when not a laptop.
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
          };
        in
        {
          homeManager.home.file.".config/DankMaterialShell/settings.json".text = builtins.toJSON settings;
        }
      ))
    ];
  };
}
