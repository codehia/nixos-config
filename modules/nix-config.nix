{ ... }:
{
  # Factory Aspect: accepts username parameter
  den.aspects.nix-config = username: {
    nixos =
      { pkgs, ... }:
      {
        environment.binsh = "${pkgs.bash}/bin/bash";
        nix = {
          optimise = {
            automatic = true;
            dates = [ "03:45" ];
          };
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            auto-optimise-store = true;
            trusted-users = [
              "root"
              username
            ];
          };
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };
      };
  };
}
