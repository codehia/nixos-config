{
  description = "My basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakeUtils.url = "github:numtide/flake-utils";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, unstable, homeManager, flakeUtils, ... }:
    flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstablePkgs = unstable.legacyPackages.${system};
      in
      {
        legacyPackages.homeConfigurations."deus" = homeManager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ./desktop.nix ];
          extraSpecialArgs = {
            unstable = unstablePkgs;
          };
        };
      }
    );
}
