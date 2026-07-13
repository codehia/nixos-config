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
          ])
          ++ (with pkgs.unstable; [
            obsidian
            # 26.05 siyuan builds with insecure pnpm_9; move back once the pnpm bump is backported
            siyuan
          ])
          ++ [
            inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-desktop
          ];
      };
  };
}
