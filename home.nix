{ config, pkgs, ... }:

{
  home = {
    stateVersion = "23.05";
    username = "deus";
    homeDirectory = "/home/deus";
    packages = [
      pkgs.htop
      pkgs.git
      pkgs.neovim
    ];
    services = {
      fstirm.enable = true;
      openssh = {
        enable = true;
        permitRootLogin = "no";
        passwordAuthentication = false;
      };
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Soumyaranjan Acharya";
      userEmail = "dev@sacharya.dev";
    };
    systemd.user.startServices = "sd-switch";
  };
}
