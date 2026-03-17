_: {
  den.aspects.nh = {
    nixos = _: {
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 7d --keep 5";
        };
      };
    };
  };
}
