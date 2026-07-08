{ den, lib, ... }:
let
  personalCalibre =
    { user, ... }:
    lib.optionalAttrs (user.personalApps or false) {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.calibre ];
        };
    };
in
{
  den.aspects.apps = {
    includes = [ personalCalibre ];
  };
}
