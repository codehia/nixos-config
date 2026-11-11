# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# Applied on the NixOS side; homes see it too via home-manager.useGlobalPkgs.
{ inputs, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      # The host's nixpkgs config, so den.batteries.unfree allowlists apply to
      # pkgs.unstable too (den nixpkgs guide).
      inherit (final) config;
    };
  };
in
{
  den.default = {
    nixos.nixpkgs.overlays = [ unstableOverlay ];
  };
}
