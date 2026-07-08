{ den, lib, ... }:
let
  personalCreative =
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
    };
in
{
  den.aspects.apps = {
    includes = [ personalCreative ];
  };
}
