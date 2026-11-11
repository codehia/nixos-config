# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# Applied on the NixOS side; homes see it too via home-manager.useGlobalPkgs.
{ den, inputs, ... }:
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
  # Host-only: den.schema.host.includes, not den.default (which users walk too).
  den = {
    aspects.unstable-overlay.nixos.nixpkgs.overlays = [ unstableOverlay ];
    schema.host.includes = [ den.aspects.unstable-overlay ];
  };
}
