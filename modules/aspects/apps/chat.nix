{ den, ... }:
{
  den.aspects.personal-apps = {
    includes = [
      (den.batteries.unfree [
        "signal-desktop"
        "telegram-desktop"
      ])
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          telegram-desktop
          signal-desktop
        ];
      };
  };
}
