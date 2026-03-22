{ den, ... }:
{
  den.aspects.qbittorrent = {
    # Open the BitTorrent port at the system level — a prerequisite for
    # receiving incoming connections regardless of which user runs the app.
    nixos =
      { ... }:
      {
        networking.firewall = {
          allowedTCPPorts = [ 7498 ];
          allowedUDPPorts = [ 7498 ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.qbittorrent ];
      };
  };
}
