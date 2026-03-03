{ ... }:
{
  # Factory Aspect: accepts username parameter
  den.aspects.nix-config = username: {
    nixos =
      { ... }:
      {
        nix = {
          optimise = {
            automatic = true;
            dates = [ "03:45" ];
          };
          settings = {
            download-buffer-size = 524288000; # 500 MiB
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
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
