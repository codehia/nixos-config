{ den, lib, ... }:
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "signal-desktop"
        "discord"
      ])
      (den.lib.perUser (
        { user, ... }:
        lib.optionalAttrs (user.personalApps or false) {
          homeManager =
            { pkgs, ... }:
            {
              home.packages = with pkgs; [
                # telegram-desktop # build failing on 6.4.1, skip until nixpkgs updates
                signal-desktop-bin
              ];
            };
        }
      ))
    ];
  };
}
