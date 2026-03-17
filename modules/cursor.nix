_: {
  den.aspects.cursor = {
    homeManager =
      { pkgs, ... }:
      {
        home.pointerCursor = {
          name = "phinger-cursors-light";
          package = pkgs.phinger-cursors;
          size = 32;
          gtk.enable = true;
        };
      };
  };
}
