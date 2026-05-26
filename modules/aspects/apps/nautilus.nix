# GUI file manager — Nautilus with archive integration and USB auto-mount.
{ den, ... }:
{
  den.aspects.apps = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nautilus
          file-roller
        ];

        dconf.settings."org/gnome/nautilus/preferences".fts-enabled = false;

        xdg.configFile."gtk-3.0/bookmarks".text = ''
          smb://thinkpad.local/public Thinkpad Public
        '';

        services.udiskie = {
          enable = true;
          automount = true;
          notify = false;
          tray = "never";
        };
      };
  };
}
