# Personal host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den = {
    hosts.x86_64-linux.personal = {
      settings = {
        nix-config.nhClean = true;
        lact.gpuKey = "1002:7340-1043:04E6-0000:2d:00.0";
        greetd = {
          user = "deus";
          # Starts the greeter's "Hyprland" entry (hyprland.nix); uwsm re-reads its args.
          session = "uwsm start hyprland-uwsm.desktop";
        };
        browser = {
          default = "helium";
          extra = [ "google-chrome" ];
        };
      };
      users.deus = { };
    };

    aspects = {
      # deus on this host only (den host-qualified aspect).
      "deus@personal".includes = [
        den.aspects.localsend
        den.aspects.gaming
      ];

      personal = {
        nixos.imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        includes = [
          den.aspects.desktop-host
          den.aspects.rtsx-card-reader
          den.aspects.mullvad
          den.aspects.lact
          den.aspects.ios-devices
          den.aspects.kanata
        ];
      };
    };
  };
}
