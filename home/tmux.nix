{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    newSession = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      (tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-dotbar";
        version = "714ba5994f8857571d6146b1f3612949ae91f820"; # Or a specific tag/commit hash
        src = pkgs.fetchFromGitHub {
          owner = "vaaleyard";
          repo = "tmux-dotbar";
          rev = "714ba5994f8857571d6146b1f3612949ae91f820";
          sha256 = "sha256-n9k18pJnd5mnp9a7VsMBmEHDwo3j06K6/G6p7/DTyIY=";
        };
      })
    ];
  };
}
