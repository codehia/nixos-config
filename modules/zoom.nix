{ ... }:
{
  den.aspects.zoom = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.zoom-us ];
      };
  };
}
