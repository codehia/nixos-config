# LACT — Linux AMD GPU Control Tool.
# Provides fan control, power cap, and clock monitoring for AMD discrete GPUs.
# NOT useful for laptop APUs (fan is EC-controlled, not GPU-controlled).
#
# Usage:
#   den.aspects.lact {}                       # daemon only, configure via GUI
#   den.aspects.lact { gpuKey = "..."; }      # declarative silent fan curve
#
# gpuKey format: "<vendor>:<device>-<subvendor>:<subdevice>-<pci_addr>"
# To find your key:
#   1. lspci -nn | grep -i vga
#      → e.g. "2d:00.0 ... [1002:7340]" gives vendor=1002, device=7340, pci_addr=0000:2d:00.0
#   2. cat /sys/class/drm/card1/device/subsystem_vendor   → e.g. 0x1043
#      cat /sys/class/drm/card1/device/subsystem_device   → e.g. 0x04e6
#      (strip the 0x prefix)
#   3. Combine: "1002:7340-1043:04e6-0000:2d:00.0"
# Known keys:
#   personal  (RX 5500 XT, Navi 14): "1002:7340-1043:04e6-0000:2d:00.0"
#
# NOTE: When settings.gpus is set, /etc/lact/config.yaml becomes a read-only symlink.
#       The LACT GUI cannot save changes — all tuning must be done declaratively here.
{
  den.aspects.lact =
    {
      gpuKey ? null,
    }:
    {
      nixos =
        { lib, ... }:
        {
          # Overdrive required for fan control to work on RDNA1+
          hardware.amdgpu.overdrive.enable = true;

          services.lact = {
            enable = true;
            settings = lib.mkMerge [
              {
                daemon = {
                  log_level = "warn";
                  admin_group = "wheel";
                };
              }
              (lib.mkIf (gpuKey != null) {
                gpus = {
                  ${gpuKey} = {
                    fan_control_enabled = true;
                    fan_control_settings = {
                      mode = "curve";
                      temperature_key = "edge";
                      interval_ms = 500;
                      # Silent curve — fans off until 50°C, ramp gently, full speed only at 90°C
                      curve = {
                        "40" = 0.0;
                        "50" = 0.0;
                        "60" = 0.2;
                        "70" = 0.35;
                        "80" = 0.6;
                        "90" = 1.0;
                      };
                      spindown_delay_ms = 5000; # 5s delay before spinning down (avoids flapping)
                      change_threshold = 3; # only change speed if delta > 3% (reduces noise)
                    };
                  };
                };
              })
            ];
          };
        };
    };
}
