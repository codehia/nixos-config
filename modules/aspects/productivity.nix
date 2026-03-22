{
  den.aspects.productivity = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            libreoffice-still
            kdePackages.okular
          ])
          ++ (with pkgs.unstable; [
            obsidian
          ]);
      };
  };
}
