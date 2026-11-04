{
  flake-file.inputs.apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

  den.aspects.apple-fonts = {
    nixos =
      { inputs', ... }:
      {
        fonts.packages = with inputs'.apple-fonts.packages; [
          sf-pro
          sf-mono
          ny
        ];
      };
  };
}
