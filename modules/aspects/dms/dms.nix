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
    dgop = {
      url = "github:AvengeMedia/dgop";
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
