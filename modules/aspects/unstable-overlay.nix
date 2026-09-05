# Unstable overlay — makes nixpkgs-unstable packages available as pkgs.unstable.*
# This avoids needing specialArgs; any module can use `pkgs.unstable.<pkg>`.
#
# den.schema.conf:  Applied to all hosts, users, and homes.
# den.default:    Applied to every host's NixOS and home-manager evaluations.
#
# NOTE: modules/schema.nix defines the same overlay for den.schema.conf.
# Keep the nixpkgs `config` below in sync with it.
{ inputs, lib, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        # beekeeper-studio bundles an EOL Electron. Allowed by name (not by
        # pinned version) so it survives version bumps.
        allowInsecurePredicate = pkg: lib.getName pkg == "beekeeper-studio";
      };
    };
  };
in
{
  den.default = {
    nixos.nixpkgs.overlays = [ unstableOverlay ];
    homeManager.nixpkgs.overlays = [ unstableOverlay ];
  };
}
