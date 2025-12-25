_: {
  programs.lazygit = {
    enable = true;
    settings = {
      disableStartupPopups = true;
      confirmOnQuit = false;
      notARepository = "skip";
    };
  };

}
