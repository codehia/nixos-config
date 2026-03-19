{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    nixos =
      { ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
          age.keyFile = "/var/lib/sops/age/keys.txt";
        };
      };

    homeManager =
      { config, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops = {
          age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };
  };
}
