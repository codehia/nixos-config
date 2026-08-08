{ den, lib, ... }:
let
  personalChat =
    { user, ... }:
    lib.optionalAttrs (user.personalApps or false) {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            telegram-desktop
            signal-desktop
          ];
        };
    };
in
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "signal-desktop"
        "telegram-desktop"
        "discord"
      ])
      personalChat
    ];
  };
}
