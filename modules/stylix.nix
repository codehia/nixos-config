{inputs, ...}: {
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.stylix = {
    homeManager = {pkgs, ...}: {
      imports = [inputs.stylix.homeModules.stylix];
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        targets = {
          # zen-browser.profileNames = ["Default Profile"];
          waybar.enable = false;
          tmux.enable = false;
          hyprland.enable = false;
          hyprlock.enable = false;
          ghostty.enable = false;
          qt.enable = false;
          kitty.enable = false;
          nvf.enable = false;
          fzf.enable = false;
        };
      };
    };
  };
}
