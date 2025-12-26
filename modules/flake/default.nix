# modules/flake/default.nix
# Auto-imports all flake modules in this directory
{
  imports = [
    ./toplevel.nix
  ];
}
