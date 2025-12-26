# configurations/nixos/workstation/default.nix
# Workstation-specific NixOS configuration (desktop)
{ flake, ... }:
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

  # Desktop-specific options
  machine = {
    gcDays = 15;
    isLaptop = false;
  };

  # Host identity
  networking.hostName = "workstation";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Boot console mode (max for desktop monitor)
  boot.loader.systemd-boot.consoleMode = "max";

  # Desktop hardware
  hardware.bluetooth.powerOnBoot = false;

  # TODO: Re-enable kanata after fixing config
  # services.kanata = {
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
  # systemd.services.kanata-internalKeyboard.serviceConfig = {
  #   SupplementaryGroups = [
  #     "input"
  #     "uinput"
  #   ];
  # };
}
