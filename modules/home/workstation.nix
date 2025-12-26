# modules/home/workstation.nix
# Workstation-specific home-manager configuration
{ pkgs, ... }:
{
  # Packages specific to workstation (desktop)
  home.packages = with pkgs; [
    slack # Work communication
  ];

  # Disable kanshi on workstation (single fixed monitor)
  services.kanshi.enable = false;
}
