# Leave evidence after an unclean reboot: panic instead of hanging, hardware
# watchdog reboot on a freeze, frequent journal syncs, RAS (MCE/PCIe) logging.
# Panic logs land in /var/lib/systemd/pstore (systemd-pstore, enabled by default).
# Usage: den.aspects.crash-diagnostics (host-side)
{
  den.aspects.crash-diagnostics.nixos = {
    # Flush journal to disk every 10s (default 5min) so less is lost on a hard reset.
    services.journald.extraConfig = "SyncIntervalSec=10s";

    boot = {
      kernelParams = [ "oops=panic" ];
      kernel.sysctl = {
        "kernel.panic" = 10; # reboot 10s after a panic
        "kernel.softlockup_panic" = 1;
        "kernel.hung_task_panic" = 1;
      };
    };

    # sp5100_tco (/dev/watchdog) reboots the machine if systemd stops pinging it.
    systemd.settings.Manager.RuntimeWatchdogSec = "30s";

    hardware.rasdaemon.enable = true;
  };
}
