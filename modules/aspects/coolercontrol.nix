# CoolerControl — fan/pump control daemon (coolercontrold) + GUI.
# Usage: den.aspects.coolercontrol (host-side)
#
# Motherboard fans (Nuvoton NCT6687D-R, MSI B550): in-tree nct6683 exposes PWM
# read-only, so it is blacklisted for the out-of-tree nct6687d driver, which can write.
{
  den.aspects.coolercontrol.nixos =
    { config, ... }:
    {
      programs.coolercontrol.enable = true;

      boot = {
        extraModulePackages = [ config.boot.kernelPackages.nct6687d ];
        kernelModules = [ "nct6687" ];
        blacklistedKernelModules = [ "nct6683" ];
      };
    };
}
