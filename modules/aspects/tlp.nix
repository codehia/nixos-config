# TLP — laptop power management for ThinkPad (AMD).
# Tuned for ThinkPad X1 Carbon / AMD: CPU, GPU, battery thresholds, USB, disk.
{ den, ... }:
{
  den.aspects.tlp = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.tlp ];
        # rtsx_pci calls pm_runtime_allow() at probe, so the reader runtime-
        # suspends and misses card-insert events. Must match ACTION=="bind" —
        # "add" fires before probe and the driver overwrites it.
        # The TLP denylist below only stops TLP from setting it back to auto.
        services.udev.extraRules = ''
          ACTION=="bind", SUBSYSTEM=="pci", DRIVER=="rtsx_pci", ATTR{power/control}="on"
        '';
        services.tlp = {
          enable = true;
          settings = {
            # ----- CPU -----
            CPU_DRIVER_OPMODE_ON_AC = "active";
            CPU_DRIVER_OPMODE_ON_BAT = "active";
            CPU_SCALING_GOVERNOR_ON_AC = "powersave";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_BOOST_ON_AC = 1;
            CPU_BOOST_ON_BAT = 0;
            CPU_HWP_DYN_BOOST_ON_AC = 1;
            CPU_HWP_DYN_BOOST_ON_BAT = 0;

            # ----- Platform Profile -----
            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";

            # ----- GPU (AMD) -----
            RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
            RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
            RADEON_DPM_STATE_ON_AC = "performance";
            RADEON_DPM_STATE_ON_BAT = "battery";
            AMDGPU_ABM_LEVEL_ON_AC = 0;
            AMDGPU_ABM_LEVEL_ON_BAT = 3;

            # ----- Disk -----
            SATA_LINKPWR_ON_AC = "med_power_with_dipm";
            SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
            AHCI_RUNTIME_PM_ON_AC = "on";
            AHCI_RUNTIME_PM_ON_BAT = "auto";
            AHCI_RUNTIME_PM_TIMEOUT = 15;

            # ----- PCIe / Runtime PM -----
            RUNTIME_PM_ON_AC = "on";
            RUNTIME_PM_ON_BAT = "auto";
            # RTS522A card reader misses card-insert while runtime-suspended —
            # keep it awake (default denylist + rtsx_pci). Matches by driver, so
            # it covers both thinkpad and workstation regardless of PCI address.
            RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon rtsx_pci";
            PCIE_ASPM_ON_AC = "default";
            PCIE_ASPM_ON_BAT = "powersupersave";

            # ----- Network -----
            WIFI_PWR_ON_AC = "off";
            WIFI_PWR_ON_BAT = "on";
            WOL_DISABLE = "Y";

            # ----- USB -----
            USB_AUTOSUSPEND = 1;
            USB_EXCLUDE_AUDIO = 1;
            USB_EXCLUDE_BTUSB = 0;
            USB_EXCLUDE_PHONE = 1;
            USB_EXCLUDE_PRINTER = 1;

            # ----- Audio -----
            SOUND_POWER_SAVE_ON_AC = 1;
            SOUND_POWER_SAVE_ON_BAT = 1;
            SOUND_POWER_SAVE_CONTROLLER = "Y";

            # ----- Kernel -----
            NMI_WATCHDOG = 0;

            # ----- Battery (ThinkPad) -----
            START_CHARGE_THRESH_BAT0 = 75;
            STOP_CHARGE_THRESH_BAT0 = 80;
          };
        };
      };
  };
}
