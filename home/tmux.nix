{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    plugins = with pkgs; [
      tmuxPlugins.dotbar
    ];
  };
}
