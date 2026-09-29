{
  den,
  lib,
  ...
}:
let
  personalMedia =
    { user, ... }:
    lib.optionalAttrs (user.personalApps or false) {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            vlc
            spotify
            # stable's ente-desktop still builds on EOL electron_41
            unstable.ente-desktop
          ];
        };
    };
in
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "spotify"
        "spotify-unwrapped"
      ])
      {
        homeManager =
          { pkgs, ... }:
          {
            home.packages = with pkgs; [
              kdePackages.gwenview
            ];
          };
      }
      personalMedia
    ];
  };
}
