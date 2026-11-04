{
  den.aspects.vcs = {
    homeManager.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
      # fish.nix has its own prompt hook (adds FISH_DIR_ENV sourcing) that runs
      # `direnv export`; HM's hook would run it a second time.
      enableFishIntegration = false;
    };
  };
}
