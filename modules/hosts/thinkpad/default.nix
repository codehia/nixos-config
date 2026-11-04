# Thinkpad host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.thinkpad = {
    home-manager.enable = true;
    nhCleanEnabled = true;
    isLaptop = true;
    greetdUser = "deus";
    greetdSessionBin = "mango";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [
      "rclone"
      "music-arr"
      "gaming"
    ];
    defaultBrowser = "helium";
    extraBrowsers = [
      "firefox-esr"
      "google-chrome"
    ];
    users.deus = {
      personalApps = true;
    };
    users.soumya = { };
  };

  den.aspects.thinkpad = {
    nixos.imports = [
      ./_hardware-configuration.nix
      ./_disko-config.nix
    ];

    includes = [
      den.aspects.desktop-host
      den.aspects.rtsx-card-reader
      den.aspects.mullvad
      den.aspects.ios-devices
      den.aspects.laptop
      den.aspects.bluetooth
    ];
  };
}
