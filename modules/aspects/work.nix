{ den, ... }:
{
  den.aspects.work = {
    includes = [
      den.aspects.zoom
      (den._.unfree [ "slack" ])
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.slack ];
      };
  };
}
