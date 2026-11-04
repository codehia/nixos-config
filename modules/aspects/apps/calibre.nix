{ den, lib, ... }:
let
  personalCalibre =
    { user, ... }:
    lib.optionalAttrs user.personalApps {
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
