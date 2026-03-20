# Shared networking baseline: NetworkManager + Tailscale firewall rules.
# Tailscale service itself is declared per-host (workstation uses custom port/package).
# hostname is read from host.hostName (set by den from the den.hosts key).
{ den, ... }:
{
  den.aspects.networking = {
    includes = [
      (den.lib.perHost (
        { host }:
        {
          nixos.networking = {
            hostName = host.hostName;
            networkmanager.enable = true;
            firewall = {
              trustedInterfaces = [ "tailscale0" ];
              checkReversePath = "loose";
            };
          };
        }
      ))
    ];
  };
}
