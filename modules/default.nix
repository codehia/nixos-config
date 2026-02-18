# Global defaults — config applied to every host and user.
# den.default sets baseline NixOS and home-manager options across all hosts.
{den, ...}: {
  den.default = {nixos.system.stateVersion = "25.11";};
}
