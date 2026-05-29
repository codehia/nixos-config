{
  den,
  lib,
  ...
}:
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
      (
        { user, ... }:
        lib.optionalAttrs (user.personalApps or false) {
          homeManager =
            { pkgs, ... }:
            {
              home.packages = with pkgs; [
                vlc
                spotify
                ente-desktop
              ];
            };
        }
      )
    ];
  };
}
