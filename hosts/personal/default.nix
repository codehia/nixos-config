# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:
let

  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "deus";
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
        "deus"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
  };

  # Use the systemd-boot EFI boot loader.
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

  # Configure network connections interactively with nmcli or nmtui.
  networking = {
    hostName = "personal";
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

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

  # Enable pipewire for audio
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  # };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fish
    libimobiledevice
    ifuse
    idevicerestore
  ];

  programs = {
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services = {
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
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11";

}
