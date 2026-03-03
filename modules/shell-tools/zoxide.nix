{ ... }:
{
  den.aspects.shell-tools = {
    homeManager =
      { ... }:
      {
        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
  };
}
