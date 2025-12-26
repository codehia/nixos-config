# modules/nixos/default.nix
# Shared NixOS modules imported by all hosts
{ flake, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./common.nix
    ./fonts.nix
  ];
}
