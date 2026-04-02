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
            devenv
          ])
          ++ (with pkgs.unstable; [
            httpie-desktop
            github-copilot-cli
          ]);
      };
  };
}
