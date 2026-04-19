# Thinkpad host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.thinkpad = {
    home-manager.enable = true;
    isLaptop = true;
    nhCleanEnabled = true;
    greetdUser = "deus";
    greetdSessionBin = "sway";
    wm = "swayfx";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [ "hyprland" ];
    nvimLanguages = [
      "lua"
      "nix"
      "python"
      "typescript"
      "go"
      "latex"
    ];
    users.soumya = {
      nvimLanguages = [
        "nix"
        "lua"
        "python"
        "typescript"
      ];
    };
    users.deus = {
      personalApps = true;
    };
  };

  den.aspects.thinkpad = {
    nixos = {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      services = {
        upower.enable = true;
        libinput = {
          enable = true;
          touchpad = {
            accelSpeed = "0.5";
          };
        };
      };
    };

    includes = [
      # Core system
      den.aspects.nix-config
      den.aspects.networking
      den.aspects.boot
      den.aspects.sudo
      den.aspects.disko

      # Nix tooling
      den.aspects.nix-tools

      # Hardware
      den.aspects.mullvad
      den.aspects.avahi
      den.aspects.tlp
      den.aspects.bluetooth
      den.aspects.tailscale
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.ios-devices
      den.aspects.zram

      den.aspects.core-services
      den.aspects.desktop-services

      # Desktop
      den.aspects.dms
      den.aspects.greetd
      den.aspects.dconf
      den.aspects.fonts
      den.aspects.gnome-keyring
    ];
  };
}
