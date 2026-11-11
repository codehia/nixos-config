{ den, ... }:
{
  den.aspects.personal-apps = {
    includes = [
      (den.batteries.unfree [
        "signal-desktop"
        "telegram-desktop"
        "discord"
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
