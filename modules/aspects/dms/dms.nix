# DankMaterialShell — NixOS system module.
# Lives in host includes only — fires once per host.
# HM user config lives in den.aspects.dms-home (dms-home.nix) — included per user.
{
  inputs,
  den,
  ...
}:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
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
        };
        # DMS enables power-profiles-daemon by default, which conflicts with TLP.
        services.power-profiles-daemon.enable = false;
      };
  };
}
