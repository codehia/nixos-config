{ den, ... }:
{
  den.aspects.tailscale = {
    nixos =
      { pkgs, ... }:
      {
        services.tailscale = {
          enable = true;
          package = pkgs.unstable.tailscale;
          openFirewall = true;
        };
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          checkReversePath = "loose";
        };
      };
  };
}
