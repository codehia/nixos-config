{ den, ... }:
{
  den.aspects.dev-tools = {
    includes = [
      (den.batteries.unfree [ "httpie-desktop" ])
    ];

    nixos.virtualisation.docker.enable = true;
    user.extraGroups = [ "docker" ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            just
            devbox
            nodejs # claude-code plugin hooks (caveman) shell out to `node`
            python3
            python3Packages.ipython
          ])
          ++ (with pkgs.unstable; [
            httpie-desktop
            beekeeper-studio
            devenv
          ]);
      };
  };
}
