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
    extraAspects = [ "rclone" ];
    extraBrowsers = [
      "firefox-esr"
      "google-chrome"
    ];
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
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];
        powerManagement.resumeCommands = ''
          ${pkgs.kmod}/bin/modprobe -r rtsx_pci_sdmmc rtsx_pci
          ${pkgs.kmod}/bin/modprobe rtsx_pci rtsx_pci_sdmmc
        '';
      };

    includes = [
      den.aspects.base-system
      den.aspects.graphical-session
      den.aspects.tailscale
      den.aspects.desktop-services
      den.aspects.mullvad
      den.aspects.avahi
      den.aspects.samba
      den.aspects.ios-devices
      den.aspects.laptop
      den.aspects.bluetooth
      den.aspects.gaming
    ];
  };
}
