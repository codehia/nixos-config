# Base system bundle — universal aspects safe for any host (desktop or server).
{ den, ... }:
{
  den.aspects.base-system = {
    includes = [
      den.aspects.nix-config
      den.aspects.networking
      den.aspects.boot
      den.aspects.sudo
      den.aspects.disko
      den.aspects.nix-tools
      den.aspects.zram
    ];
  };
}
