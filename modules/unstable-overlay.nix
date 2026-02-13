# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# den.base.conf:  Applied at the flake-parts perSystem level (devShells, checks, etc.)
# den.default:    Applied to every host's NixOS and home-manager evaluations.
{inputs, ...}: let
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
in {
  den.base.conf = {
    nixpkgs.overlays = [unstableOverlay];
  };

  den.default = {
    nixos.nixpkgs.overlays = [unstableOverlay];
    homeManager.nixpkgs.overlays = [unstableOverlay];
  };
}
