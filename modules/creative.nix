_: {
  den.aspects.creative = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          inkscape
          obs-studio
        ];
      };
  };
}
