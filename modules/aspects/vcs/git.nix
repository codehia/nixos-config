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
            options = {
              features = lib.mkForce "side-by-side line-numbers";
            };
          };

          git = {
            enable = true;
            includes = [ { path = "~/.config/delta/themes.gitconfig"; } ];
            settings = {
              core.editor = "vim";
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
