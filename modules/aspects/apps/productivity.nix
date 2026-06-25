{ den, inputs, ... }:
{
  flake-file.inputs.zennotes = {
    url = "github:ZenNotes/zennotes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

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
            siyuan
          ])
          ++ (with pkgs.unstable; [
            obsidian
          ])
          ++ [
            inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-desktop
          ];
      };
  };
}
