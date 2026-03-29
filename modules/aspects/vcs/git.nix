{
  den.aspects.vcs = {
    homeManager =
      { pkgs, lib, ... }:
      let
        deltaThemes = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/dandavison/delta/main/themes.gitconfig";
          hash = "sha256-kPGzO4bzUXUAeG82UjRk621uL1faNOZfN4wNTc1oeN4=";
        };
      in
      {
        programs = {
          delta = {
            enable = true;
            enableGitIntegration = true;
            options = {
              features = lib.mkForce "side-by-side line-numbers decorations";
              navigate = "true";
              dark = "true";
              lineNumbers = "true";
              sideBySide = "true";
            };
          };

          git = {
            enable = true;
            includes = [ { path = "${deltaThemes}"; } ];
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
