{
  disko.devices = {
    disk = {
      # --- FAST DRIVE (main system) ---
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks_root = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-main";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };

      # --- SLOW DRIVE (archive & backups) ---
      # Swap removed — zramSwap handles memory pressure (see personal.nix).
      # Subvolumes can be extended as needed without repartitioning.
      slow = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            luks_archive = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-slow";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/backups" = {
                      mountpoint = "/var/lib/btrbk";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
