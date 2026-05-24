{ den, lib, ... }:
{
  den.aspects.apps = {
    includes = [
      (
        { user, ... }:
        lib.optionalAttrs (user.personalApps or false) {
          homeManager =
            { pkgs, ... }:
            {
              home.packages = with pkgs; [
                inkscape
                obs-studio
              ];
            };
        }
      )
    ];
  };
}
