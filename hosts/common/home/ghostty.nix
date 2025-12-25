{ pkgs-unstable, ... }:
{
  programs.ghostty = {
    package = pkgs-unstable.ghostty;
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 16;
      cursor-style = "block";
      cursor-style-blink = true;
      shell-integration-features = "no-cursor";
      theme = "catppuccin-mocha";
      window-padding-balance = true;
      window-decoration = false;
      keybind = "ctrl+enter=unbind";
    };
  };
}
