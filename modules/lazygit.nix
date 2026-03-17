_: {
  den.aspects.lazygit = {
    homeManager = _: {
      programs.lazygit = {
        enable = true;
        settings = {
          disableStartupPopups = true;
          confirmOnQuit = false;
          notARepository = "skip";
        };
      };
    };
  };
}
