{ den, ... }:
{
  den.aspects.nix-config = {
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
            # root is always trusted; each user is appended via perUser below.
            trusted-users = [ "root" ];
            max-jobs = "auto";
            http-connections = 50;
            max-substitution-jobs = 128;
          };
          gc = {
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };
      };

    includes = [
      # nh manages GC when nhCleanEnabled — disable the built-in automatic GC in that case.
      (den.lib.perHost (
        { host }:
        {
          nixos.nix.gc.automatic = !(host.nhCleanEnabled or false);
        }
      ))

      # Add each host user to trusted-users (listOf merges by concatenation).
      (den.lib.perUser (
        { user, ... }:
        {
          nixos.nix.settings.trusted-users = [ user.userName ];
        }
      ))
    ];
  };
}
