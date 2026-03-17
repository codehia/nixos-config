_: {
  den.aspects.shell-tools = {
    homeManager = _: {
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        tmux.enableShellIntegration = true;
      };
    };
  };
}
