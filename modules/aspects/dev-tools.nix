{ den, ... }:
let
  dockerGroup =
    { user, ... }:
    {
      nixos.users.users.${user.userName}.extraGroups = [ "docker" ];
    };
in
{
  den.aspects.dev-tools = {
    includes = [
      (den._.unfree [ "httpie-desktop" ])
      dockerGroup
    ];

    nixos.virtualisation.docker.enable = true;

    homeManager =
      { pkgs, ... }:
      {
        home.packages =
          (with pkgs; [
            just
            devbox
            cruft
            cookiecutter
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
