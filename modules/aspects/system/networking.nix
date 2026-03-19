# Shared networking baseline: NetworkManager + Tailscale firewall rules.
# Tailscale service itself is declared per-host (workstation uses custom port/package).
{
  den.aspects.networking =
    { hostname }:
    {
      nixos.networking = {
        hostName = hostname;
        networkmanager.enable = true;
        firewall = {
          trustedInterfaces = [ "tailscale0" ];
          checkReversePath = "loose";
        };
      };
    };
}
