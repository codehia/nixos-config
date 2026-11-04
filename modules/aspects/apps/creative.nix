{ den, lib, ... }:
let
  personalCreative =
    { user, ... }:
    lib.optionalAttrs user.personalApps {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            inkscape
            (unstable.wrapOBS {
              plugins = with unstable.obs-studio-plugins; [ obs-backgroundremoval ];
            })
          ];
        };
    };
in
{
  den.aspects.apps = {
    includes = [ personalCreative ];
  };
}
