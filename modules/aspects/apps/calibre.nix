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
              home.packages = [ pkgs.calibre ];
            };
        }
      )
    ];
  };
}
