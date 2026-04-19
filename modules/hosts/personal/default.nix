# Personal host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.personal = {
    home-manager.enable = true;
    gpuKey = "1002:7340-1043:04E6-0000:2d:00.0";
    nhCleanEnabled = true;
    greetdUser = "deus";
    greetdSessionBin = "sway";
    wm = "swayfx";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [ ];
    nvimLanguages = [
      "lua"
      "nix"
      "python"
      "typescript"
      "go"
      "latex"
    ];
    users.deus = {
      personalApps = true;
    };
  };

  den.aspects.personal = {
    nixos = {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];
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
      den.aspects.tailscale
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.lact
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
