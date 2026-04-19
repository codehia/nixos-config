# Core desktop services — enabled on all graphical hosts.
{ den, ... }:
{
  den.aspects.core-services = {
    nixos.services = {
      gvfs.enable = true;
      fwupd.enable = true;
    };
  };
}
