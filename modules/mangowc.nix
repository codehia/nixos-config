{inputs, ...}: {
  flake-file.inputs.mango = {
    url = "github:DreamMaoMao/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.mangowc = {
    nixos = {...}: {
      imports = [inputs.mango.nixosModules.mangowc];
      mango = {
        enable = true;
      };
    };
  };
}
