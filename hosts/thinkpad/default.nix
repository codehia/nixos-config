# Nix will match by name and automatically inject the inputs
# from specialArgs/_module.args into the third parameter of this function
{ pkgs, ... }:
let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  username = "deus";
  session = "/etc/profiles/per-user/${username}/bin/start-hyprland";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/nixos/fonts.nix
  ];
  nix = {
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        username
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "2";
      };
      efi.canTouchEfiVariables = true;
    };
    plymouth = {
      enable = true;
      theme = "connect";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "connect" ];
        })
      ];
    };
    initrd = {
      verbose = false;
      systemd.enable = true;
      kernelModules = [ "amdgpu" ];
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_level=3"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    kernelModules = [ "uinput" ];
    consoleLogLevel = 0;
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

  security = {
    sudo = {
      wheelNeedsPassword = false;
    };
    pam.services = {
      greetd.enableGnomeKeyring = true;
      greetd-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };
  users.users.deus = {
    isNormalUser = true;
    description = "Soumyaranjan Acharya";
    initialPassword = "Soumya$321";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.fish;
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
    appimage.enable = true;
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
    kanata = {
      enable = true;
      keyboards = {
        # internalKeyboard = {
        #   devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];
        #   extraDefCfg = "process-unmapped-keys yes";
        #   configFile = ../common/nixos/regular_keyboard.kbd;
        # };
        kinesis = {
          devices = [
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          configFile = ../common/nixos/kinesis.kbd;
        };
      };
    };
    dbus.packages = with pkgs; [
      gnome-keyring
      gcr
    ];
    usbmuxd.enable = true;
    flatpak.enable = true;
    gvfs.enable = true;
    tailscale.enable = true;
    openssh.enable = true;
    gnome.gnome-keyring.enable = true;
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
          command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time -cmd ${session}";
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
  # systemd.services.kanata-internalKeyboard.serviceConfig = {
  #   SupplementaryGroups = [
  #     "input"
  #     "uinput"
  #   ];
  # };
  system.stateVersion = "25.05";
}
