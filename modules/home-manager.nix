# Home-manager integration — declares the flake input and sets default home-manager config.
#
# Home-manager is now enabled per-host via den.hosts.<system>.<hostname>.home-manager.enable = true.
# User accounts are created automatically by den when users are declared in den.hosts.
{ lib, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Enable homeManager class for all users (required for den to import the HM NixOS module).
  # Without this, den.ctx.hm-host never activates and home-manager.* NixOS options don't exist.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    nixos.home-manager.backupFileExtension = "hm-backup";
    homeManager.home.stateVersion = "25.11";
  };
}
