{ den, ... }:
{
  flake-file.inputs = {
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  den.aspects.dev-tools = {
    includes = [ (den.batteries.unfree [ "claude-code" ]) ];

    homeManager =
      { inputs', ... }:
      {
        home.packages = [ inputs'.claude-code.packages.default ];
      };
  };
}
