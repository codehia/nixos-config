{ den, ... }:
{
  den.aspects.zoom = {
    includes = [
      (den.batteries.unfree [
        "zoom"
        "zoom-us"
      ])
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.zoom-us ];
      };
  };
}
