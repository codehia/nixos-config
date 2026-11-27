{
  flakeInput = {
    url = "github:AlvaroParker/helium-nix";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  package = inputs': inputs'.helium.packages.default;
  command = "helium";
  desktop = "helium.desktop";
}
