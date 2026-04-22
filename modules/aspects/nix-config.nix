{ den, ... }:
{
  den.aspects.nix-config = {
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
          optimise = {
            automatic = true;
            dates = [ "03:45" ];
          };
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
              "https://niri.cachix.org"
              "https://devenv.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
            auto-optimise-store = true;
            # root is always trusted by nix daemon.
            # Per-user entries are added via perUser in defaults.nix.
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
    ];
  };
}
