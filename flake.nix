{
  description = "My basic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
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
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        cognixm = pkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/configuration.nix
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
