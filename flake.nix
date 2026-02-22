# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix/release-25.11";
    };
    den.url = "github:vic/den";
    dgop = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:AvengeMedia/dgop";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    dms = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:AvengeMedia/DankMaterialShell/stable";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };
    hyprland = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hyprland";
    };
    import-tree.url = "github:vic/import-tree";
    mango = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:DreamMaoMao/mango";
    };
    nfsm.url = "github:gvolpe/nfsm";
    niri-flake = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:sodiboo/niri-flake";
    };
    niri-scratchpad.url = "github:gvolpe/niri-scratchpad";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    noctalia = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:noctalia-dev/noctalia-shell";
    };
    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix/release-25.11";
    };
    sway-scratch = {
      flake = false;
      url = "github:aokellermann/sway-scratch";
    };
    systems.url = "github:nix-systems/default";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };
}
