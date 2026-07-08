# Shared networking baseline: NetworkManager + Tailscale firewall rules.
# Tailscale service itself is declared per-host (workstation uses custom port/package).
# hostname is read from host.hostName (set by den from the den.hosts key).
{ den, ... }:
let
  hostNetworking =
    { host }:
    {
      nixos.networking = {
        hostName = host.hostName;
        networkmanager.enable = true;
      };
    };
in
{
  den.aspects.networking = {
    includes = [ hostNetworking ];
  };
}
