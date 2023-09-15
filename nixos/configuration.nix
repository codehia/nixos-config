{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  users = {
    defaultUserShell = pkgs.zsh;
    users.deus = {
      isNormalUser = true;
      initialPassword = "password";
      description = "Soumyaranjan Acharya";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };
  programs = {
    zsh.enable = true;
    dconf.enable = true;
  };
  boot = {
    consoleLogLevel = 0;
    plymouth.enable = true;
    kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" "boot.shell_on_fail" ];
    initrd = {
      systemd.enable = true;
      verbose = false;
      secrets = { "/crypto_keyfile.bin" = null; };
      luks.devices = {
        "luks-462d91b8-2f7c-4583-aa48-6706da6eb61c" = {
          device = "/dev/disk/by-uuid/462d91b8-2f7c-4583-aa48-6706da6eb61c";
          keyFile = "/crypto_keyfile.bin";
        };
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  networking = {
    hostName = "cognixm"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

  };
  environment = {
    etc."vimrc".text = ''
      set mouse=
      set ttymouse=
      set ts=4 sw=4
      set rnu
      set clipboard=unnamedplus
    '';
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [ vim_configurable wget git ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services = {
    fstrim.enable = true;
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    dbus = { enable = true; };
    xserver = {
      videoDrivers = [
        "amdgpu"
      ];
      enable = true;
      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
      displayManager = {
        defaultSession = "none+xmonad";
        autoLogin = {
          enable = true;
          user = "deus";
        };
      };
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
    kanata = let configFile = builtins.readFile ./kanata.kbd;
    in {
      enable = true;
      keyboards = {
        keychron = {
          devices =
            [ "/dev/input/by-id/usb-Keychron_Keychron_K8_Pro-event-kbd" ];
          config = configFile;
        };
        thinkpad = {
          devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
          config = configFile;
        };
      };
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
