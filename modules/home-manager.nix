# Home-manager integration — declares the flake input and enables it for all hosts.
#
# den._.home-manager:  Wires up the home-manager NixOS module for each host.
# den._.define-user:   Creates the NixOS user account for each user declared in den.hosts.
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
