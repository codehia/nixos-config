# modules/home/thinkpad.nix
# Thinkpad-specific home-manager configuration
{ pkgs, pkgs-unstable, ... }:
{
  # Packages specific to thinkpad (laptop)
  home.packages =
    (with pkgs; [
      # Laptop-specific apps
      qbittorrent
      brightnessctl # Screen brightness control
      zoom-us

      # Messaging (personal use)
      signal-desktop-bin
      telegram-desktop
    ])
    ++ (with pkgs-unstable; [
      obsidian
    ]);

  # Kanshi profiles for thinkpad (multi-monitor management)
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@60.03300";
              scale = 1.0;
              position = "0,0";
              status = "enable";
            }
          ];
        };
      }
      {
        profile = {
          name = "azanDocked";
          outputs = [
            {
              criteria = "BNQ BenQ GW2480 BCP0111201Q";
              mode = "1920x1080@60.00Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }
      {
        profile = {
          name = "miniDocked";
          outputs = [
            {
              criteria = "Samsung Electric Company LF24T35 HNAR101094";
              mode = "1920x1080@74.97300";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "LG Electronics LG HDR WQHD 0x0001991D";
              mode = "3440x1440@75.05Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }
    ];
  };
}
