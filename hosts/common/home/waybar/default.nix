{ lib, ... }:
let
  configJsonData = lib.importJSON ./waybar.json;
  configCssData = ./waybar.css;
in {
  programs.waybar = {
    enable = true;
    settings = [ configJsonData ];
    style = lib.mkForce configCssData;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };
}
