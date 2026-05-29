{
  den.aspects.tui = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          htop
          btop
          iotop
          iftop
          ncdu
          fastfetch
          pulsemixer
          bluetui

          # system diagnostics
          strace
          ltrace
          lsof
          sysstat
          lm_sensors
          ethtool
          pciutils
          usbutils
        ];
      };
  };
}
