# Laptop bundle — power management and input aspects for laptop hosts.
{ den, ... }:
{
  den.aspects.laptop = {
    includes = [
      den.aspects.tlp
      den.aspects.upower
      den.aspects.libinput
    ];
  };
}
