{
  description = "My basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, homeManager, ... }@inputs: {
    nixosConfigurations = {
      cognixm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          homeManager.homeManagerConfiguration.home-manager
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
