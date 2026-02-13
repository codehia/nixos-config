{ inputs, ... }:
{
  flake-file.inputs.apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

  den.aspects.apple-fonts = {
    nixos = { pkgs, ... }: 
    {
        fonts.packages = with inputs.apple-fonts.packages.${pkgs.system}; [ sf-pro sf-mono ny ];
    };
  };
}
