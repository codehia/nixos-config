{
  flakeInput = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  package = inputs': inputs'.zen-browser.packages.beta;
  command = "zen-beta";
  desktop = "zen-beta.desktop";
}
