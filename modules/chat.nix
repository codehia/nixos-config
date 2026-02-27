{...}: {
  den.aspects.chat = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        telegram-desktop
        signal-desktop-bin
      ];
    };
  };
}
