{ den, ... }:
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "1password"
        "1password-cli"
        "1password-gui"
        "bitwarden-desktop"
        "bitwarden-cli"
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
            bitwarden-desktop
            bitwarden-cli
            ente-auth
            obsidian
          ])
          ++ (with pkgs.unstable; [
            # 26.05 siyuan builds with insecure pnpm_9; move back once the pnpm bump is backported
            siyuan
          ]);
      };
  };
}
