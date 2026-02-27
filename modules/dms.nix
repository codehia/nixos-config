# DankMaterialShell — all-in-one Wayland shell built on Quickshell & Go.
# Replaces waybar, notifications, lock screen, launcher, OSD, clipboard, system monitor.
# Factory aspect (takes username) following the noctalia pattern.
#
# To activate: add (den.aspects.dms username) to thinkpad.nix includes
# (and remove den.aspects.noctalia if active).
{inputs, ...}: {
  flake-file.inputs.dms = {
    url = "github:AvengeMedia/DankMaterialShell/stable";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  flake-file.inputs.dgop = {
    url = "github:AvengeMedia/dgop";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.dms = username: {
    nixos = {pkgs, ...}: {
      imports = [inputs.dms.nixosModules.dank-material-shell];
      programs.dank-material-shell = {
        enable = true;
        dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
      # DMS enables power-profiles-daemon by default, which conflicts with TLP.
      services.power-profiles-daemon.enable = false;
    };

    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      imports = [inputs.dms.homeModules.dank-material-shell];

      home.file.".config/DankMaterialShell/settings.json".source = ./dms-settings.json;

      # Sync wallpapers from config repo to ~/Pictures/Wallpapers.
      home.activation.syncWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
        wallpaperSrc="/home/${username}/nixos-config/assets/.wallpapers"
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
  };
}
