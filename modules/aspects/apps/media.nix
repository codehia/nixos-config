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
      (den.lib.perUser (
        { user, ... }:
        lib.optionalAttrs (user.personalApps or false) {
          homeManager =
            { pkgs, ... }:
            {
              home.packages = with pkgs; [
                vlc
                spotify
              ];
            };
        }
      ))
    ];
  };
}
