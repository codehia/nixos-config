{lib, ...}: {
   programs.git = {
      enable = true;
      userName = "codehia";
      userEmail = "dev@sacharya.dev";
      extraConfig = {
        core = { editor = "vim"; };
        # interactive = { diffFilter = "delta --color-only"; };
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

      delta = {
        enable = true;
        options = {
          features = lib.mkForce "side-by-side line-numbers decorations";
          navigate = "true";
          dark = "true";
          lineNumbers = "true";
          sideBySide = "true";
        };
      };
    };
}
