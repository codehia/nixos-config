{
  den.aspects.vcs = {
    homeManager.programs.lazygit = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        disableStartupPopups = true;
        confirmOnQuit = false;
        notARepository = "skip";
        git.pagers = [
          {
            colorArg = "always";
            pager = "delta --paging=never --features='mellow-barbet'";
            useConfig = false;
          }
        ];
      };
    };
  };
}
