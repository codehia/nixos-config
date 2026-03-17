_: {
  den.aspects.shell-tools = {
    homeManager = _: {
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
