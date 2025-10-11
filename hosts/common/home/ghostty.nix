_: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 14;
      adjust-cell-height = "20%";
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
