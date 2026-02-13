{
  description = "Soumya's Multi-Machine NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin = {
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # flake-parts
  # outputs = inputs@ {flake-parts, ...}:
  #    flake-parts.lib.mkFlake {inherit inputs; } (top@{config, withSystem, moduleWithSystem, ... }: {
  #       imports = [];
  #       flake = {};
  #       systems = ["x86_64-linux"];
  #       perSystem = { config, pkgs, ... }: {
  #
  #       };
  # });

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      disko,
      home-manager,
      catppuccin,
      zen-browser,
      sops-nix,
      stylix,
      nixCats,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # List of allowed unfree packages (add new packages here as needed)
      # This provides granular control over which unfree software is permitted
      allowedUnfree = [
        "1password"
        "1password-cli"
        "1password-gui"
        "slack"
        "spotify"
        "spotify-unwrapped"
        "zoom"
        "zoom-us"
        "discord"
        "vscode"
        "obsidian"
        "mullvad"
        "mullvad-vpn"
        "brave"
        "signal-desktop"
        "obsidian"
        "google-chrome"
      ];
      # Create pkgs-unstable for use in home-manager
      pkgs-unstable = import nixpkgs-unstable {
        system = system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs-unstable.lib.getName pkg) allowedUnfree;
        };
      };
    in
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit pkgs-unstable;
          };
          modules = [
            # Configure nixpkgs with allowUnfree BEFORE other modules
            {
              nixpkgs.config = {
                allowUnfree = true;
                allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
              };
            }
            ./hosts/thinkpad
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                users.deus = {
                  imports = [
                    ./hosts/common/home
                    catppuccin.homeModules.catppuccin
                    zen-browser.homeModules.beta
                    sops-nix.homeManagerModules.sops
                    stylix.homeModules.stylix
                  ];
                  # Configure nixpkgs for home-manager
                  nixpkgs.config = {
                    allowUnfree = true;
                    allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
                  };
                };
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit inputs;
                  inherit pkgs-unstable;
                };
              };
            }
          ];
        };

        workstation = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit pkgs-unstable;
          };
          modules = [
            # Configure nixpkgs with allowUnfree BEFORE other modules
            {
              nixpkgs.config = {
                allowUnfree = true;
                allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
              };
            }
            ./hosts/workstation
            disko.nixosModules.disko
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                users.deus = {
                  imports = [
                    ./hosts/common/home
                    catppuccin.homeModules.catppuccin
                    zen-browser.homeModules.beta
                    sops-nix.homeManagerModules.sops
                    stylix.homeModules.stylix
                  ];
                  # Configure nixpkgs for home-manager
                  nixpkgs.config = {
                    allowUnfree = true;
                    allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowedUnfree;
                  };
                };
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit inputs;
                  inherit pkgs-unstable;
                };
              };
            }
          ];
        };

        personal = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            inherit pkgs-unstable;
          };
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
                extraSpecialArgs = {
                  inherit inputs;
                  inherit pkgs-unstable;
                };
              };
            }
          ];
        };
      };
    };
}
