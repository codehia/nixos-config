{
  den,
  lib,
  ...
}:
let
  personalMedia =
    { user, ... }:
    lib.optionalAttrs user.personalApps {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            vlc
            # stable's ente-desktop still builds on EOL electron_41
            unstable.ente-desktop
          ];
        };
    };
in
{
  den.aspects.apps = {
    includes = [
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
