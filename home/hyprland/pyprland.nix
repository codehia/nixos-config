{pkgs, ...}: {
  home.packages = with pkgs; [pyprland];
  home.file.".config/hypr/pyprland.toml".source = ./pyprland.toml;
}
