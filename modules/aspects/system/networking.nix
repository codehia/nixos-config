# Shared networking baseline: NetworkManager (the firewall is on by NixOS default).
# hostname is set by the den.batteries.hostname battery (defaults.nix).
{
  den.aspects.networking = {
    nixos.networking.networkmanager.enable = true;
  };
}
