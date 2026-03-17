_: {
  den.aspects.dev-tools = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            just
            nixfmt-classic
            nix-output-monitor
          ])
          ++ (with pkgs.unstable; [
            devenv
            vscode
            claude-code
            httpie-desktop
          ]);
      };
  };
}
