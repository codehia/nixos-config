# LACT — Linux AMD GPU Control Tool.
# Provides fan control, power cap, and clock monitoring for AMD discrete GPUs.
# NOT useful for laptop APUs (fan is EC-controlled, not GPU-controlled).
#
# gpuKey is a freeform host attribute (set in hosts.nix) — read via perHost.
# Usage: den.aspects.lact
#
# gpuKey format: "<vendor>:<device>-<subvendor>:<subdevice>-<pci_addr>"
# To find your key: sudo lact cli list
#   → e.g. "1002:7340-1043:04E6-0000:2d:00.0 (AMD Radeon RX 5500 XT)"
#   Use the key exactly as lact reports it — lact normalizes hex to uppercase,
#   so sysfs values (e.g. 0x04e6) won't match; the key must be uppercase.
# Known keys:
#   personal  (RX 5500 XT, Navi 14): "1002:7340-1043:04E6-0000:2d:00.0"
#
# NOTE: curve keys must be integers in YAML — Nix attrset keys are always strings,
#       so services.lact.settings cannot be used for the fan curve.
#
# NOTE: environment.etc cannot be used for config.yaml — lact writes to its config at
#       startup, so a read-only Nix store symlink causes an immediate crash. Config is
#       written via ExecStartPre (pkgs.writeText → cp) to a writable /etc/lact/config.yaml.
#       The LACT GUI cannot save changes (config is overwritten on each service start).
{ den, ... }:
{
  den.aspects.lact = {
    nixos = {
      # Overdrive required for fan control to work on RDNA1+
      hardware.amdgpu.overdrive.enable = true;
      services.lact.enable = true;
    };

    includes = [
      (den.lib.perHost (
        { host }:
        let
          gpuKey = host.gpuKey or null;
        in
        {
          nixos =
            { lib, pkgs, ... }:
            let
              configText = ''
                daemon:
                  log_level: warn
                  admin_group: wheel
              ''
              + lib.optionalString (gpuKey != null) ''
                gpus:
                  ${gpuKey}:
                    fan_control_enabled: true
                    fan_control_settings:
                      mode: curve
                      temperature_key: edge
                      interval_ms: 500
                      spindown_delay_ms: 6000
                      change_threshold: 2
                      curve:
                        35: 0.0
                        50: 0.0
                        60: 0.20
                        70: 0.35
                        78: 0.52
                        85: 0.72
                        95: 1.0
              '';
              # Store config in the Nix store; ExecStartPre copies it to a writable path.
              configFile = pkgs.writeText "lact-config.yaml" configText;
            in
            {
              systemd.services.lactd.serviceConfig.ExecStartPre = [
                # Remove stale socket from previous run (- prefix = ignore failure if missing).
                "-/run/current-system/sw/bin/rm /run/lactd.sock"
                # Write Nix-managed config to writable /etc/lact/config.yaml before start.
                "${pkgs.writeShellScript "lact-write-config" ''
                  mkdir -p /etc/lact
                  cp ${configFile} /etc/lact/config.yaml
                ''}"
              ];
            };
        }
      ))
    ];
  };
}
