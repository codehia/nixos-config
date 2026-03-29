{
  den.aspects.vcs = {
    homeManager.programs.lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
        confirmOnQuit = false;
        notARepository = "skip";
        git.pagers = [
          {
            colorArg = "always";
            pager = "delta --paging=never --features='mellow-barbet' --syntax-theme='Catppuccin Mocha'";
            useConfig = false;
          }
        ];
        gui = {
          showRootItemInFileTree = false;
          sidePanelWidth = 0.2;
        };
      };
    };
  };
}
