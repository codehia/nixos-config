# Nix will match by name and automatically inject the inputs
# from specialArgs/_module.args into the third parameter of this function
{ pkgs, inputs, ... }: {
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
    consoleLogLevel = 0;
  };
  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
  };
  time.timeZone = "Asia/Kolkata";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "all" ];
  };

  security.sudo = { wheelNeedsPassword = false; };
  users.users.deus = {
    isNormalUser = true;
    description = "Soumyaranjan Acharya";
    initialPassword = "Soumya$321";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };
  environment.systemPackages = with pkgs; [ vim wget git fish ];
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
    gvfs.enable = true;
    tailscale.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    openssh = {
      enable = true;
      # settings.PasswordAuthentication = true;
    };
  };
  system.stateVersion = "25.05";
}
