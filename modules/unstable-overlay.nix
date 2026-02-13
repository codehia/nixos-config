{ inputs, ... }:
let
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
in
{
  den.base.conf = {
    nixpkgs.overlays = [ unstableOverlay ];
  };

  den.default = {
    nixos.nixpkgs.overlays = [ unstableOverlay ];
    homeManager.nixpkgs.overlays = [ unstableOverlay ];
  };
}
