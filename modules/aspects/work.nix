{ den, ... }:
{
  den.aspects.work = {
    includes = [
      den.aspects.zoom
      (den.batteries.unfree [ "slack" ])
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.slack ];
      };
  };
}
