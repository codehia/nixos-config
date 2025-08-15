{
  description = "Soumya's Flake configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
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
  };

  # `self` is the return value of the current flake's `outputs` function and
  # also the path to the current flake's source code folder (source tree)
  outputs = inputs @ {
    nixpkgs,
    disko,
    home-manager,
    catppuccin,
    zen-browser,
    sops-nix,
    stylix,
    ...
  }: {
    nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        ./nixos/configuration.nix
        disko.nixosModules.disko
        catppuccin.nixosModules.catppuccin
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.deus = {
              imports = [
                ./home
                catppuccin.homeModules.catppuccin
                zen-browser.homeModules.beta
                sops-nix.homeManagerModules.sops
                stylix.homeModules.stylix
              ];
            };
            backupFileExtension = "backup";
            extraSpecialArgs = {inherit inputs;};
          };
          # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
        }
      ];
    };
  };
}
