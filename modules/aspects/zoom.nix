{ den, ... }:
{
  den.aspects.zoom = {
    includes = [
      (den._.unfree [
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
