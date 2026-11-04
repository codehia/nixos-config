# Workstation host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.workstation = {
    home-manager.enable = true;
    nhCleanEnabled = true;
    greetdUser = "soumya";
    # Auto-login straight into Hyprland under UWSM (matches the greeter session entry).
    greetdSessionCmd = "/run/current-system/sw/bin/uwsm start -- Hyprland";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [ ];
    users.deus = {
      personalApps = true;
    };
    users.soumya = { };
    extraBrowsers = [ "google-chrome" ];
  };

  den.aspects.workstation = {
    nixos.imports = [
      ./_hardware-configuration.nix
      ./_disko-config.nix
    ];

    includes = [
      den.aspects.desktop-host
      den.aspects.rtsx-card-reader
    ];
  };
}
