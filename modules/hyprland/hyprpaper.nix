{ ... }:
{
  den.aspects.hyprland = {
    homeManager =
      { ... }:
      {
        services.hyprpaper = {
          enable = true;
          settings = {
            preload = [
              "~/Downloads/2019-sekiro-shadows-die-twice-4k-qr-3440x1440.jpg"
              "~/Downloads/sekiro-shadows-die-twice-2019-4k-5b-3440x1440.jpg"
            ];
            wallpaper = [
              "DP-2, ~/Downloads/sekiro-shadows-die-twice-2019-4k-5b-3440x1440.jpg"
            ];
          };
        };
      };
  };
}
