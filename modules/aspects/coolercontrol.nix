# CoolerControl — fan/pump control daemon (coolercontrold) + GUI.
# Usage: den.aspects.coolercontrol (host-side)
#
# Motherboard fans (Nuvoton NCT6687D-R, MSI B550): in-tree nct6683 exposes PWM
# read-only, so it is blacklisted for the out-of-tree nct6687d driver, which can write.
{
  den.aspects.coolercontrol.nixos =
    { config, pkgs, ... }:
    {
      programs.coolercontrol.enable = true;
      # GUI at login; it is also the tray icon.
      systemd.user.services.coolercontrol-gui = {
        description = "CoolerControl GUI";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [
          "graphical-session.target"
          "dms.service" # DMS sets the dark color-scheme the GUI follows
        ];
        serviceConfig.ExecStart = "${pkgs.coolercontrol.coolercontrol-gui}/bin/coolercontrol";
      };

      boot = {
        extraModulePackages = [ config.boot.kernelPackages.nct6687d ];
        kernelModules = [ "nct6687" ];
        blacklistedKernelModules = [ "nct6683" ];
      };
    };
}
