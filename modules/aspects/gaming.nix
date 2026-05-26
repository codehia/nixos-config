{ den, ... }:
{
  den.aspects.gaming = {
    nixos = {
      programs.steam.enable = true;
      programs.steam.remotePlay.openFirewall = true;
      programs.gamemode.enable = true;
      hardware.graphics.enable32Bit = true;
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.mangohud ];
      };

    includes = [
      (den._.unfree [
        "steam"
        "steam-original"
        "steam-unwrapped"
      ])
    ];
  };
}
