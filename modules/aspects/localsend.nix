{ den, ... }:
{
  den.aspects.localsend = {
    # LocalSend discovery + transfer port — system level so peers can reach it.
    nixos =
      { ... }:
      {
        networking.firewall = {
          allowedTCPPorts = [ 53317 ];
          allowedUDPPorts = [ 53317 ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.localsend ];
      };
  };
}
