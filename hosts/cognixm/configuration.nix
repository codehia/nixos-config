{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  services.fstirm.enable = true;
  time.timeZone = "Asia/Kolkata";
  networking.hostName = "cognixm";
  system.stateVersion = "23.05";
}
