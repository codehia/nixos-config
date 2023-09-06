{
  description = "My basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      homeManager = home-manager;
      pkgs = nixpkgs;
      age = agenix;
    in {
      nixosConfigurations = {
        cognixm = pkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/configuration.nix
            age.nixosModules.default
            homeManager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.deus = import ./home.nix;
            }
          ];
        };
      };
    };
}
