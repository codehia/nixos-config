{...}: {
  den.aspects.shell-tools = {
    homeManager = {...}: {
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        tmux.enableShellIntegration = true;
      };
    };
  };
}
