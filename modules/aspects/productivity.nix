{
  den.aspects.productivity = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            libreoffice-still
            calibre
            kdePackages.okular
          ])
          ++ (with pkgs.unstable; [
            obsidian
          ]);
      };
  };
}
