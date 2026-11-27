{
  den.aspects.vcs = {
    homeManager.programs.lazygit = {
      enable = true;
      settings = {
        disableStartupPopups = true;
        confirmOnQuit = false;
        notARepository = "skip";
        git.diffRenderers = [
          {
            colorArg = "always";
            # Look comes from programs.delta.options (git.nix), read via git config.
            command = "delta --paging=never";
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
