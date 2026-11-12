# Workstation host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den = {
    hosts.x86_64-linux.workstation = {
      settings = {
        nix-config.nhClean = true;
        greetd = {
          user = "soumya";
          # Starts the greeter's "Hyprland" entry (hyprland.nix); uwsm re-reads its args.
          session = "uwsm start hyprland-uwsm.desktop";
        };
        browser.extra = [ "google-chrome" ];
      };
      users.deus = { };
      users.soumya = { };
    };

    aspects.workstation = {
      nixos.imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      includes = [
        den.aspects.desktop-host
        den.aspects.rtsx-card-reader
      ];
    };
  };
}
