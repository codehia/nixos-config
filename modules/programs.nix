{...}: {
  den.aspects.programs = {
    homeManager = {pkgs, ...}: {
      programs = {
        gh = {
          enable = true;
          extensions = with pkgs; [
            gh-dash
            gh-poi
            gh-f
            act
          ];
        };
        nix-index = {
          enable = true;
          enableFishIntegration = true;
        };
        fzf = {
          enable = true;
          enableFishIntegration = true;
          tmux.enableShellIntegration = true;
        };
        zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    };
  };
}
