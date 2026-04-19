# Desktop integration services — flatpak, appimage, WebKit/GTK runtime libs.
{ den, ... }:
{
  den.aspects.desktop-services = {
    nixos =
      { pkgs, ... }:
      {
        services.flatpak.enable = true;
        programs.appimage.enable = true;
        environment.systemPackages = with pkgs; [
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
        ];
      };
  };
}
