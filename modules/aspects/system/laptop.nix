# Laptop bundle — power management and input aspects for laptop hosts.
{ den, ... }:
{
  den.aspects.laptop = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.brightnessctl ];
      };

    includes = [
      den.aspects.tlp
      den.aspects.upower
      den.aspects.libinput
    ];
  };
}
