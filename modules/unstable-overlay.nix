# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# den.default: Applied to every host's NixOS and home-manager evaluations.
{ inputs, ... }:
let
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
in
{
  den.default = {
    nixos.nixpkgs.overlays = [ unstableOverlay ];
    homeManager.nixpkgs.overlays = [ unstableOverlay ];
  };
}
