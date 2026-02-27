# Host aspect for thinkpad — the main NixOS system configuration.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{den, ...}: let
  username = "deus"; # Can stay here - no pkgs dependency
in {
  den.aspects.thinkpad = {
    nixos = {pkgs, ...}: let
      tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
      # hyprlandSession = "/home/${username}/.nix-profile/bin/start-hyprland";
      # MangoWC as default (pkgs.mango available via overlay from mangowc aspect)
      # session = "/home/${username}/.nix-profile/bin/mango -s /home/${username}/.config/mango/autostart.sh";
      session = "/home/${username}/.nix-profile/bin/sway";
    in {
      imports = [./_hardware-configuration.nix ./_disko-config.nix];

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
          trustedInterfaces = ["tailscale0"];
          checkReversePath = "loose";
        };
      };

      time.timeZone = "Asia/Kolkata";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocales = ["all"];
      };

      security = {
        sudo.wheelNeedsPassword = false;
        pam.services = {
          greetd.enableGnomeKeyring = true;
          greetd-password.enableGnomeKeyring = true;
          login.enableGnomeKeyring = true;
        };
      };

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
        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };
      };

      services = {
        tlp = {
          enable = true;
          settings = {CPU_SCALING_GOVERNOR_ON_BAT = "powersave";};
        };
        kanata = {
          enable = true;
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
        dbus.packages = with pkgs; [gnome-keyring gcr];
        usbmuxd.enable = true;
        flatpak.enable = true;
        gvfs.enable = true;
        tailscale.enable = true;
        openssh.enable = true;
        gnome.gnome-keyring.enable = true;
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
          touchpad = {accelSpeed = "0.5";};
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
          settings = {General = {Experimental = true;};};
        };
        graphics = {
          enable = true;
          extraPackages = with pkgs; [mesa rocmPackages.clr.icd];
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
      (den.aspects.dms username)
      den.aspects.git
      den.aspects.lazygit
      den.aspects.nvim
      den.aspects.direnv
      den.aspects.browser
      den.aspects.secrets
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
    ];
  };
}
