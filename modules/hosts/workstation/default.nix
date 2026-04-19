# Workstation host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.workstation = {
    home-manager.enable = true;
    nhCleanEnabled = true;
    greetdUser = "soumya";
    greetdSessionCmd = "uwsm start /run/current-system/sw/bin/start-hyprland";
    wm = "hyprland";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [ ];
    nvimLanguages = [
      "lua"
      "nix"
      "python"
    ];
    users.deus = {
      personalApps = true;
    };
    extraBrowsers = [ "google-chrome" ];
    users.soumya = {
      nvimLanguages = [
        "nix"
        "lua"
        "python"
        "typescript"
      ];
    };
  };

  den.aspects.workstation = {
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
      den.aspects.tailscale
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.zram

      den.aspects.core-services

      # Desktop
      den.aspects.hyprland
      den.aspects.dms
      den.aspects.greetd
      den.aspects.dconf
      den.aspects.fonts
      den.aspects.gnome-keyring
    ];
  };
}
