# Home-manager integration — declares the flake input and sets default home-manager config.
#
# Home-manager is now enabled per-host via den.hosts.<system>.<hostname>.home-manager.enable = true.
# User accounts are created automatically by den when users are declared in den.hosts.
{ den, lib, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Give all users the homeManager class by default so den imports the HM NixOS module.
  den.base.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    nixos.home-manager.backupFileExtension = "hm-backup";
    homeManager.home.stateVersion = "25.11";
  };
}
