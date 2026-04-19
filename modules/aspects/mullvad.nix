# Mullvad VPN — enables the service and allowlists unfree packages.
{ den, ... }:
{
  den.aspects.mullvad = {
    nixos =
      { pkgs, ... }:
      {
        services.mullvad-vpn = {
          enable = true;
          package = pkgs.mullvad-vpn;
        };
      };

    includes = [
      (den._.unfree [
        "mullvad"
        "mullvad-vpn"
      ])
    ];
  };
}
