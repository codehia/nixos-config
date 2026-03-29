{ den, ... }:
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "1password"
        "1password-cli"
        "1password-gui"
        "obsidian"
      ])
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            libreoffice-still
            kdePackages.okular
            _1password-gui
            ente-auth
          ])
          ++ (with pkgs.unstable; [
            obsidian
          ]);
      };
  };
}
