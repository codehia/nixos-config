# Realtek rtsx_pci SD card reader fixes (all three hosts have one).
{
  den.aspects.rtsx-card-reader = {
    nixos =
      { pkgs, ... }:
      {
        # The reader stops detecting cards after suspend; reload the driver on resume.
        powerManagement.resumeCommands = ''
          ${pkgs.kmod}/bin/modprobe -r rtsx_pci_sdmmc rtsx_pci
          ${pkgs.kmod}/bin/modprobe -a rtsx_pci rtsx_pci_sdmmc
        '';
        # rtsx_pci calls pm_runtime_allow() at probe, so the reader runtime-
        # suspends and misses card-insert events. Must match ACTION=="bind" —
        # "add" fires before probe and the driver overwrites it.
        # (tlp.nix's RUNTIME_PM_DRIVER_DENYLIST stops TLP setting it back to auto.)
        services.udev.extraRules = ''
          ACTION=="bind", SUBSYSTEM=="pci", DRIVER=="rtsx_pci", ATTR{power/control}="on"
        '';
      };
  };
}
