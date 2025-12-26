# Top-level flake glue for nixos-unified autowiring
{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
  ];

  perSystem =
    { self', pkgs, ... }:
    {
      # For 'nix fmt'
      formatter = pkgs.nixpkgs-fmt;

      # Enables 'nix run' to activate configuration
      packages.default = self'.packages.activate;
    };
}
