{ ... }:
{
  den.aspects.shell-tools = {
    homeManager =
      { pkgs, ... }:
      {
        programs.gh = {
          enable = true;
          extensions = with pkgs; [
            gh-dash
            gh-poi
            gh-f
            act
          ];
        };
      };
  };
}
