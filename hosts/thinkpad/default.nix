# Nix will match by name and automatically inject the inputs
# from specialArgs/_module.args into the third parameter of this function
{ pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "deus";
in {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ../common/nixos/fonts.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nix = {
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "deus" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
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
      themePackages = with pkgs;
        [
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
  };
  time.timeZone = "Asia/Kolkata";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "all" ];
  };

  security = {
    sudo = { wheelNeedsPassword = false; };
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
    extraGroups = [ "wheel" "networkmanager" ];
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
  services = {
    dbus.packages = with pkgs; [gnome-keyring gcr];
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
          command =
            "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time -cmd ${session}";
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
      touchpad = { accelSpeed = "0.5"; };
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
      settings = { General = { Experimental = true; }; };
    };
  };
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [ "input" "uinput" ];
  };
};
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };
  system.stateVersion = "25.05";
}
