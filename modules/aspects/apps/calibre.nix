{ den, lib, ... }:
{
  den.aspects.apps = {
    includes = [
      (den.lib.perUser (
        { user, ... }:
        lib.optionalAttrs (user.personalApps or false) {
          homeManager =
            { pkgs, ... }:
            {
              home.packages = [ pkgs.calibre ];
            };
        }
      ))
    ];
  };
}
