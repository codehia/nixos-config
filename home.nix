{ config, pkgs, ... }:

{
  home.username = "deus";
  home.homeDirectory = "/home/deus";

  home.packages = [
    pkgs.htop
  ];

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
