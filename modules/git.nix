{ ... }:
{
  den.aspects.git = {
    homeManager =
      { lib, ... }:
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
