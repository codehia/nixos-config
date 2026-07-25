{ inputs, ... }:
{
  den.aspects.shell-tools = {
    homeManager = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
