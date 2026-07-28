{
  den.aspects.terminal = {
    homeManager =
      { pkgs, ... }:
      {
        programs.ghostty = {
          package = pkgs.unstable.ghostty;
          enable = true;
          enableFishIntegration = true;
          installBatSyntax = true;
          systemd.enable = true;
          settings = {
            font-family = "JetBrainsMono Nerd Font,JetBrainsMono NF";
            font-size = 14;
            cursor-style = "block";
            cursor-style-blink = false;
            shell-integration-features = "no-cursor";
            window-padding-balance = true;
            window-decoration = false;
            gtk-single-instance = true; # route every `ghostty` to the clean systemd service
            keybind = "ctrl+enter=unbind";
          };
        };
      };
  };
}
