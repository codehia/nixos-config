{...}: {
  den.aspects.tui = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        htop
        btop
        iotop
        iftop
        ncdu
        pulsemixer
        bluetui
      ];
    };
  };
}
