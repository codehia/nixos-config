{ inputs, ... }:
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.catppuccin = {
    nixos =
      { ... }:
      {
        imports = [ inputs.catppuccin.nixosModules.catppuccin ];
      };

    homeManager =
      { ... }:
      {
        imports = [ inputs.catppuccin.homeModules.catppuccin ];
        catppuccin = {
          flavor = "mocha";
          enable = true;
          fish.enable = true;
          fzf.enable = true;
          kitty.enable = true;
          ghostty.enable = true;
          nvim.enable = true;
          hyprland.enable = true;
          lazygit.enable = true;
          rofi.enable = false;
          tmux.enable = false;
        };
      };
  };
}
