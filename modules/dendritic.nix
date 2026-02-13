# Core infrastructure — bootstraps the dendritic pattern.
#
# den:          Declarative host/user/aspect management (the "dendritic" module system).
# flake-file:   Lets individual modules declare flake inputs inline; aggregated by `nix run .#write-flake`.
# import-tree:  Auto-discovers all .nix files in modules/ (files prefixed with _ are excluded).
# flake-parts:  The underlying flake module system (mkFlake).
# flake-aspects: Provides the aspect composition primitives used by den.
{inputs, ...}: {
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.den.flakeModules.dendritic
  ];

  flake-file.inputs = {
    den = {
      url = "github:vic/den";
    };
    flake-file = {
      url = "github:vic/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
    flake-aspects = {
      url = "github:vic/flake-aspects";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
  };

  # Only building for x86_64-linux (thinkpad). Add more systems here for other architectures.
  systems = ["x86_64-linux"];
}
