# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# den.schema.conf:  Applied to all hosts, users, and homes.
# den.default:    Applied to every host's NixOS and home-manager evaluations.
{ inputs, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
in
{
  den.schema.conf = {
    nixpkgs.overlays = [ unstableOverlay ];
  };

  den.default = {
    nixos.nixpkgs.overlays = [ unstableOverlay ];
    homeManager.nixpkgs.overlays = [ unstableOverlay ];
  };
}
