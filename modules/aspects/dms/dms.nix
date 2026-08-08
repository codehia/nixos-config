# DankMaterialShell — NixOS system module.
# Lives in host includes only — fires once per host.
# HM user config lives in den.aspects.dms-home (dms-home.nix) — included per user.
{ inputs, ... }:
{
  flake-file.inputs = {
    wallpapers = {
      url = "git+https://codeberg.org/codehia/wallpapers";
      flake = false;
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Pinned: dgop HEAD (d57055f "go: update dependencies", 2026-08-05) ships a
    # stale vendorHash in its own flake.nix — go.mod deps changed but the hash
    # wasn't bumped, so it fails with a fixed-output hash mismatch. 267c9d2 is
    # the last good rev ("flake: update vendorHash for go.mod changes").
    # Unpin once upstream fixes the vendorHash.
    dgop = {
      url = "github:AvengeMedia/dgop/267c9d25adb784a4ac2daa90eae0c281074ea03f";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Override quickshell — DMS stable pins 2025-12-25 which predates:
    # - layer-shell placeholder screen crash fix (2026-02-22)
    # - QTBUG-145022 null proxy crash fix (2026-03-16)
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den.aspects.dms = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.dms.nixosModules.dank-material-shell ];
        programs.dank-material-shell = {
          enable = true;
          dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
          quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        };
        # DMS enables power-profiles-daemon by default, which conflicts with TLP.
        services.power-profiles-daemon.enable = false;
      };
  };
}
