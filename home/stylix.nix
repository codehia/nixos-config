{ pkgs, ... }: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    targets = {
      waybar.enable = false;
      tmux.enable = false;
      # rofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      ghostty.enable = false;
      qt.enable = false;
      kitty.enable = false;
      nvf.enable = false;
      fzf.enable = false;
      starship.enable = false;
      # qt = {
      #   enable = false;
      #   platformTheme.name = "kvantum";
      #   platform = "kvantum";
      # };
    };
  };
}
