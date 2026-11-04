let
  # GC policy: host.nhCleanEnabled picks nh clean or the built-in nix.gc timer.
  # Both are set from the one flag so they can never run together.
  gcPolicy =
    { host }:
    {
      nixos = {
        programs.nh.clean.enable = host.nhCleanEnabled;
        nix.gc = {
          automatic = !host.nhCleanEnabled;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };
    };
in
{
  den.aspects.nix-config = {
    includes = [ gcPolicy ];

    nixos =
      { pkgs, config, ... }:
      {
        sops.secrets.GITHUB_ACCESS_TOKEN = {
          sopsFile = ../../secrets/common.yaml;
          mode = "0444"; # world-readable — nix client reads !include as the user, not root
        };

        # The secret value in common.yaml must be a valid nix.conf line:
        #   access-tokens = github.com=<token>
        # !include defers reading to nix-daemon startup, after sops has decrypted the secret.
        nix.extraOptions = ''
          !include ${config.sops.secrets.GITHUB_ACCESS_TOKEN.path}
        '';

        environment.binsh = "${pkgs.bash}/bin/bash";
        nix = {
          settings = {
            download-buffer-size = 524288000; # 500 MiB
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://hyprland.cachix.org"
              "https://devenv.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
            auto-optimise-store = true;
            # root is always trusted by nix daemon.
            # Per-user entries are added via perUser in defaults.nix.
            max-jobs = "auto";
            http-connections = 50;
            max-substitution-jobs = 128;
            fallback = true; # build locally if a cached NAR is advertised but missing
          };
        };
      };
  };
}
