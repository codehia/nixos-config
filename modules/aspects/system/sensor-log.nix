# Exposes hardware and system metrics for Prometheus on casa, which scrapes them over
# Tailscale; the data lives off this PC, so a hard reset loses nothing.
# node_exporter :9100 (sensors, CPU, power, PSI, memory, disks, GPU via drm), scraped every 1 s.
# smartctl_exporter :9633 (SSD SMART health), scraped every 60 s.
# Reachable only over tailscale0 (trusted interface); no firewall port is opened.
# Scrape config lives on casa: /srv/docker/prometheus/prometheus.yml
# Usage: den.aspects.sensor-log (host-side)
{
  den.aspects.sensor-log.nixos = {
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "drm" ];
      };
      smartctl = {
        enable = true;
        # Block devices (group disk); autodiscovery picks /dev/nvmeN, which is root-only.
        devices = [
          "/dev/disk/by-id/nvme-KIOXIA-EXCERIA_with_Heatsink_SSD_842F704GFA5S"
          "/dev/disk/by-id/nvme-UMIS_RPETJ256MGE2MDQ_SS0L25216X4RC21J8102"
        ];
      };
    };

    # rapl collector (CPU package power): energy_uj is root-only (0400).
    systemd.services.prometheus-node-exporter.serviceConfig = {
      AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
      CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
    };
  };
}
