{
  den.aspects.ghostty = {
    homeManager =
      { pkgs, ... }:
      {
        programs.ghostty = {
          package = pkgs.unstable.ghostty;
          enable = true;
          enableFishIntegration = true;
          installBatSyntax = true;
          settings = {
            font-family = "JetBrainsMono Nerd Font,JetBrainsMono NF";
            font-size = 14;
            cursor-style = "block";
            cursor-style-blink = true;
            shell-integration-features = "no-cursor";
            window-padding-balance = true;
            window-decoration = false;
            keybind = "ctrl+enter=unbind";
          };
        };
      };
  };
}
