# Host aspect for thinkpad — the main NixOS system configuration.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
let
  username = "deus"; # Can stay here - no pkgs dependency
in
{
  den.aspects.thinkpad = {
    nixos =
      { pkgs, ... }:
      let
        tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
        # hyprlandSession = "/home/${username}/.nix-profile/bin/start-hyprland";
        # MangoWC as default (pkgs.mango available via overlay from mangowc aspect)
        # session = "/home/${username}/.nix-profile/bin/mango -s /home/${username}/.config/mango/autostart.sh";
        session = "/home/${username}/.nix-profile/bin/sway";
      in
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        zramSwap = {
          enable = true;
          priority = 100;
          algorithm = "lz4";
          memoryPercent = 50;
        };
        networking = {
          hostName = "thinkpad";
          networkmanager.enable = true;
          firewall = {
            trustedInterfaces = [ "tailscale0" ];
            checkReversePath = "loose";
          };
        };

        time.timeZone = "Asia/Kolkata";

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocales = [ "all" ];
        };

        security.sudo.wheelNeedsPassword = false;

        environment.systemPackages = with pkgs; [
          vim
          wget
          git
          fish
          libimobiledevice
          ifuse
          idevicerestore
          tlp
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
        ];

        programs = {
          dconf.enable = true;
          appimage.enable = true;
          fish.enable = true;
        };

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
          usbmuxd.enable = true;
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
          greetd = {
            enable = true;
            settings = {
              initial_session = {
                command = "${session}";
                user = "${username}";
              };
              default_session = {
                command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --cmd '${session}'";
                user = "greeter";
              };
            };
          };
          pipewire = {
            enable = true;
            pulse.enable = true;
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
              };
            };
          };
          graphics = {
            enable = true;
            extraPackages = with pkgs; [
              mesa
              rocmPackages.clr.icd
            ];
          };
        };
      };

    includes = [
      (den.aspects.nix-config username)
      den.aspects.boot
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fonts
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.kitty
      den.aspects.tmux
      den.aspects.swayfx
      (den.aspects.dms {
        username = username;
        isLaptop = true;
      })
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
      den.aspects.rclone
      den.aspects.gnome-keyring
    ];
  };
}
