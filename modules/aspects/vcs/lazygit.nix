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
            pager = "delta --paging=never --features='mellow-barbet' --syntax-theme='Catppuccin Mocha' --plus-style='syntax #1e3626' --minus-style='syntax #36201e' --plus-emph-style='syntax #2d5238' --minus-emph-style='syntax #5c3230'";
            useConfig = false;
          }
        ];
        gui = {
          nerdFontsVersion = "3";
          tabWidth = 2;
          sidePanelWidth = 0.2;
          showRootItemInFileTree = false;
        };
      };
    };
  };
}
