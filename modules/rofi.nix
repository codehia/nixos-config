{...}: {
  den.aspects.rofi = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
        extraConfig = {
          modi = "drun,filebrowser,run";
          show-icons = true;
          icon-theme = "Papirus";
          font = "JetBrainsMono Nerd Font 12";
          drun-display-format = "{icon} {name}";
          display-drun = " Apps";
          display-run = "  Run";
          display-window = " 﩯 Window";
          display-Network = " 󰤨  Network";
          display-filebrowser = " File";
        };
        theme = lib.mkForce ./catppuccin-mocha.rasi;
      };
    };
  };
}
