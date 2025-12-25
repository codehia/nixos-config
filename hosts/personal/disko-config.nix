{
  disko.devices = {
    disk = {
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

      # --- SLOW DRIVE CONFIGURATION ---
      slow = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            # Partition 1: Dedicated Hibernation/Swap
            swap = {
              size = "34G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # Signals usage for hibernation
                priority = 0; # Lowest priority (Last resort)
              };
            };
            # Partition 2: Archive & Backup
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
                    "/nix-cache" = {
                      mountpoint = "/var/lib/nix-cache";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/bulk" = {
                      mountpoint = "/mnt/bulk";
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
