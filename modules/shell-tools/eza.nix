_: {
  den.aspects.shell-tools = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.eza ];
      };
  };
}
