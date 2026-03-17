_: {
  den.aspects.packages = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          vim
          wget
          git
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cowsay
          fortune
          fastfetch
          gearlever
          qbittorrent

          # system tools
          strace
          ltrace
          lsof
          sysstat
          lm_sensors
          ethtool
          pciutils
          usbutils
          libglvnd
          libglibutil

          # file management
          xfce.thunar
          xfce.thunar-volman

          # security
          gnupg
          age
          ssh-to-age
          _1password-gui
          _1password-cli
          ente-auth

          brightnessctl
          brave
        ];
      };
  };
}
