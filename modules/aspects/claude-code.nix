{ den, ... }:
{
  flake-file.inputs = {
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  den.aspects.dev-tools = {
    includes = [
      (den._.unfree [ "claude-code" ])
      {
        homeManager =
          { pkgs, ... }:
          {
            home.packages = [ pkgs.claude-code ];
          };
      }
    ];
  };
}
