{ den, ... }:
{
  den.aspects.apps = {
    includes = [
      (den.batteries.unfree [
        "bitwarden-desktop"
        "bitwarden-cli"
        "obsidian"
      ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        libreoffice-still
        kdePackages.okular
        bitwarden-desktop
        bitwarden-cli
        ente-auth
        obsidian
      ];
    };
  };
}
