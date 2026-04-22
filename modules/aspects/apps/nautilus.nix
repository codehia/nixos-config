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

        services.udiskie = {
          enable = true;
          automount = true;
          notify = false;
          tray = "never";
        };
      };
  };
}
