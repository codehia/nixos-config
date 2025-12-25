{
  description = "Soumya's Multi-Machine NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      catppuccin,
      zen-browser,
      sops-nix,
      stylix,
      nixCats,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/thinkpad
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.deus = {
                  imports = [
                    ./hosts/common/home
                    catppuccin.homeModules.catppuccin
                    zen-browser.homeModules.beta
                    sops-nix.homeManagerModules.sops
                    stylix.homeModules.stylix
                  ];
                };
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/workstation
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.deus = {
                  imports = [
                    ./hosts/common/home
                    catppuccin.homeModules.catppuccin
                    zen-browser.homeModules.beta
                    sops-nix.homeManagerModules.sops
                    stylix.homeModules.stylix
                  ];
                };
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        personal = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/personal
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.deus = {
                  imports = [
                    ./hosts/common/home
                    catppuccin.homeModules.catppuccin
                    zen-browser.homeModules.beta
                    sops-nix.homeManagerModules.sops
                    stylix.homeModules.stylix
                  ];
                };
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };
      };
    };
}
