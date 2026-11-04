{ den, ... }:
{
  den.aspects.personal-apps = {
    includes = [
      (den._.unfree [
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
