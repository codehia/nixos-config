# sway-scratch — per-app named scratchpad toggler for Sway.
# Merges into the swayfx aspect via the collector pattern.
# Builds sway-scratch from source since it's not in nixpkgs and has no flake.
{inputs, ...}: {
  flake-file.inputs.sway-scratch = {
    url = "github:aokellermann/sway-scratch";
    flake = false;
  };

  den.aspects.swayfx = {
    homeManager = {pkgs, ...}: let
      sway-scratch = pkgs.rustPlatform.buildRustPackage {
        pname = "sway-scratch";
        version = "0.2.1";
        src = inputs.sway-scratch;
        cargoLock.lockFile = "${inputs.sway-scratch}/Cargo.lock";
        meta = {
          description = "Named scratchpad manager for Sway";
          homepage = "https://github.com/aokellermann/sway-scratch";
        };
      };
    in {
      home.packages = [sway-scratch];
    };
  };
}
