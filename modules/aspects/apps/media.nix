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
        "cider-2"
        "widevine-cdm"
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
                cider-2
              ];
            };
        }
      ))
    ];
  };
}
