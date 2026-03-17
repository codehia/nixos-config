# Shared networking baseline: NetworkManager + Tailscale firewall rules.
# Tailscale service itself is declared per-host (workstation uses custom port/package).
_: {
  den.aspects.networking =
    { hostname }:
    {
      nixos = _: {
        networking = {
          hostName = hostname;
          networkmanager.enable = true;
          firewall = {
            trustedInterfaces = [ "tailscale0" ];
            checkReversePath = "loose";
          };
        };
      };
    };
}
