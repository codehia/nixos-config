{
  den.aspects.vcs = {
    homeManager =
      {
        pkgs,
        lib,
        ...
      }:
      {
        home.file.".config/delta/themes.gitconfig".source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dandavison/delta/f85c46ba8b913aa3208af0f3573db90286e56e18/themes.gitconfig";
          hash = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
        };

        programs = {
          delta = {
            enable = true;
            enableGitIntegration = true;
            # lazygit's diff pane uses these too (lazygit.nix diffRenderers).
            options = {
              # mellow-barbet (themes.gitconfig) turns on side-by-side and line-numbers itself
              features = lib.mkForce "mellow-barbet";
              syntax-theme = "Catppuccin Mocha";
              plus-style = "syntax #1e3626";
              minus-style = "syntax #36201e";
              plus-emph-style = "syntax #2d5238";
              minus-emph-style = "syntax #5c3230";
            };
          };

          git = {
            enable = true;
            includes = [ { path = "~/.config/delta/themes.gitconfig"; } ];
            settings = {
              merge = {
                tool = "delta";
                conflictStyle = "zdiff3";
              };
              diff = {
                tool = "delta";
                context = 3;
                colorMoved = "dimmed-zebra";
              };
            };
          };
        };
      };
  };
}
