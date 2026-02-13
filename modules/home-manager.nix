{den, ...}: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.default.includes = [
    den._.home-manager
    den._.define-user
  ];

  den.default = {
    nixos.home-manager.backupFileExtension = "hm-backup";
    homeManager.home.stateVersion = "25.11";
  };
}
