{ ... }:
{
  den.aspects.cursor = {
    homeManager =
      { pkgs, ... }:
      {
        home.pointerCursor = {
          name = "phinger-cursors-light";
          package = pkgs.phinger-cursors;
          size = 35;
          gtk.enable = true;
        };
      };
  };
}
