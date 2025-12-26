# configurations/home/deus.nix
# User-level home-manager configuration for deus
{
  flake,
  hostname,
  self,
  ...
}:
{
  imports = [
    self.homeModules.default
    # Import host-specific home module
    (self + /modules/home/${hostname}.nix)
  ];

  home = {
    username = "deus";
    homeDirectory = "/home/deus";
    stateVersion = "25.05";
  };
}
