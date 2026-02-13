# Catppuccin Mocha theme — applied system-wide via the catppuccin NixOS/HM modules.
# flake-file.inputs declares this module's flake input inline; run `just write-flake` to regenerate flake.nix.
{inputs, ...}: {
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.catppuccin = {
    nixos = {...}: {
      imports = [inputs.catppuccin.nixosModules.catppuccin];
    };

    homeManager = {...}: {
      imports = [inputs.catppuccin.homeModules.catppuccin];
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
