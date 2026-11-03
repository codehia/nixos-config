{ den, ... }:
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "bitwarden-desktop"
        "bitwarden-cli"
        "obsidian"
      ])
    ];

    homeManager = { pkgs, ... }: {
      # electron 43 (nixpkgs default) blanks obsidian's renderer (webFrame TypeError),
      # so obsidian stays on 42, now EOL. Pinned version on purpose: re-check on bump.
      nixpkgs.config.permittedInsecurePackages = [ "electron-42.11.18" ];
      home.packages = with pkgs; [
        libreoffice-still
        kdePackages.okular
        bitwarden-desktop
        bitwarden-cli
        ente-auth
        (obsidian.override { electron = electron_42; })
      ];
    };
  };
}
