# Host aspect for thinkpad — the main NixOS system configuration.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
let
  username = "deus";
  session = "/home/${username}/.nix-profile/bin/sway";
in
{
  den.aspects.thinkpad = {
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        time.timeZone = "Asia/Kolkata";

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocales = [ "all" ];
        };

        environment.systemPackages = with pkgs; [
          tlp
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
        ];

        programs.appimage.enable = true;

        services = {
          tlp = {
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
              PCIE_ASPM_ON_AC = "default";
              PCIE_ASPM_ON_BAT = "powersupersave";

              # ----- Network -----
              WIFI_PWR_ON_AC = "off";
              WIFI_PWR_ON_BAT = "on";
              WOL_DISABLE = "Y";

              # ----- Bluetooth -----
              # Disable BT on battery when no device is connected; re-enable on AC.
              DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth";
              DEVICES_TO_ENABLE_ON_AC = "bluetooth";

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
          kanata = {
            enable = false;
            keyboards = {
              kinesis = {
                devices = [
                  "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
                  "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
                ];
                extraDefCfg = "process-unmapped-keys yes";
                configFile = ./kinesis.kbd;
              };
            };
          };
          flatpak.enable = true;
          gvfs.enable = true;
          tailscale.enable = true;
          upower.enable = true;
          fwupd.enable = true;
          mullvad-vpn = {
            enable = true;
            package = pkgs.mullvad-vpn;
          };
          avahi = {
            enable = true;
            nssmdns4 = true;
            nssmdns6 = true;
            openFirewall = true;
          };
          pipewire.wireplumber.extraConfig.bluetoothPolicy = {
            "monitor.bluez.properties" = {
              "bluez5.auto-connect" = [
                "hfp_hf"
                "hsp_hs"
                "a2dp_sink"
              ];
              "bluez5.hw-volume" = [
                "hfp_hf"
                "hsp_hs"
                "a2dp_sink"
              ];
            };
          };
          libinput = {
            enable = true;
            touchpad = {
              accelSpeed = "0.5";
            };
          };
          udev.extraRules = ''
            KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
          '';
        };

        hardware = {
          uinput.enable = true;
          bluetooth = {
            enable = true;
            powerOnBoot = true;
            settings = {
              General = {
                Experimental = true;
                FastConnectable = true;
              };
              Policy = {
                AutoEnable = true;
                ReconnectAttempts = 7;
                ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
              };
            };
          };
          # graphics.extraPackages handled by den.aspects.graphics;
          # rocmPackages.clr.icd omitted — only needed for GPU-accelerated compute workloads
        };
      };

    includes = [
      (den.aspects.nix-config {
        inherit username;
        nhCleanEnabled = true;
      })
      den.aspects.nh
      (den.aspects.networking { hostname = "thinkpad"; })
      (den.aspects.greetd { inherit username session; })
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.ios-devices
      den.aspects.zram
      den.aspects.sudo
      den.aspects.dconf
      den.aspects.boot
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fonts
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.kitty
      den.aspects.tmux
      den.aspects.swayfx
      den.aspects.dms
      den.aspects.git
      den.aspects.lazygit
      (den.aspects.nvim {
        languages = [
          "lua"
          "nix"
          "python"
          "typescript"
          "go"
          "latex"
        ];
      })
      den.aspects.direnv
      den.aspects.browser
      den.aspects.secrets
      (den.aspects.ssh {
        sopsFile = ../../../secrets/thinkpad.yaml;
        userSopsFile = ../../../secrets/deus.yaml;
      })
      den.aspects.nix-tools
      den.aspects.packages
      den.aspects.services
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.dev-tools
      den.aspects.productivity
      den.aspects.media
      den.aspects.creative
      den.aspects.chat
      den.aspects.zoom
      den.aspects.cursor
      den.aspects.disko
      (den.aspects.rclone { inherit username; })
      den.aspects.gnome-keyring
      den.aspects.work
    ];
  };
}
