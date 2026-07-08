# Shared networking baseline: NetworkManager + Tailscale firewall rules.
# Tailscale service itself is declared per-host (workstation uses custom port/package).
# hostname is set by the den.batteries.hostname battery (defaults.nix).
{ den, ... }:
{
  den.aspects.networking = {
    nixos.networking.networkmanager.enable = true;
  };
}
