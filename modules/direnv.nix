_: {
  den.aspects.direnv = {
    homeManager = _: {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };
    };
  };
}
