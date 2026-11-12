# Thinkpad host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den = {
    hosts.x86_64-linux.thinkpad = {
      settings = {
        nix-config.nhClean = true;
        greetd = {
          user = "deus";
          session = "uwsm start hyprland-uwsm.desktop";
        };
        browser = {
          default = "helium";
          extra = [ "google-chrome" ];
        };
      };
      users.deus = { };
      users.soumya = { };
    };

    aspects = {
      # deus on this host only (den host-qualified aspect).
      "deus@thinkpad".includes = [ den.aspects.gaming ];

      thinkpad = {
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
    };
  };
}
