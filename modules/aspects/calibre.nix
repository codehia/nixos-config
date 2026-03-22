{ den, ... }:
{
  den.aspects.calibre = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.calibre ];
      };
  };
}
