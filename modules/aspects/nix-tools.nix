{ inputs, ... }:
{
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.nix-tools = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.nix-index-database.nixosModules.nix-index ];
        programs.nix-index-database.comma.enable = true;
        programs.nh = {
          enable = true;
          clean = {
            enable = true;
            extraArgs = "--keep-since 7d --keep 5";
          };
        };
        environment.systemPackages = with pkgs; [
          nix-tree
          manix
          nix-output-monitor
          nixfmt-classic
        ];
      };
  };
}
