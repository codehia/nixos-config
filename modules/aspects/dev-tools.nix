{ den, ... }:
{
  den.aspects.dev-tools = {
    includes = [ (den._.unfree [ "httpie-desktop" ]) ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            just
            devbox
          ])
          ++ (with pkgs.unstable; [
            httpie-desktop
            github-copilot-cli
            beekeeper-studio
            devenv
          ]);
      };
  };
}
