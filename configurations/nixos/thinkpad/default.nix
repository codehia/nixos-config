# configurations/nixos/thinkpad/default.nix
# Thinkpad-specific NixOS configuration (laptop)
{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.catppuccin.nixosModules.catppuccin
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # Laptop-specific options
  machine = {
    gcDays = 7;
    isLaptop = true;
  };

  # Host identity
  networking.hostName = "thinkpad";

  # Boot console mode (smaller for laptop)
  boot.loader.systemd-boot.consoleMode = "2";

  # Laptop-specific system packages
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
    idevicerestore
    tlp
    webkitgtk_6_0
    webkitgtk_4_1
    gtk4
  ];

  # Programs
  programs.appimage.enable = true;

  # Laptop-specific services
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
    # TODO: Re-enable kanata after fixing config
    # kanata = {
    #   enable = true;
    #   keyboards = {
    #     kinesis = {
    #       devices = [
    #         "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
    #         "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
    #       ];
    #       extraDefCfg = "process-unmapped-keys yes";
    #       configFile = self + /home/kanata/kinesis.kbd;
    #     };
    #   };
    # };
    dbus.packages = with pkgs; [
      gnome-keyring
      gcr
    ];
    usbmuxd.enable = true;
    flatpak.enable = true;
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
    libinput = {
      enable = true;
      touchpad = {
        accelSpeed = "0.5";
      };
    };
  };

  # Laptop hardware
  hardware.bluetooth.powerOnBoot = true;
}
