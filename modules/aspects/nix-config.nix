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
          settings = {
            download-buffer-size = 524288000; # 500 MiB
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            # cache.nixos.org and its key are added by NixOS itself.
            substituters = [
              "https://nix-community.cachix.org"
              "https://devenv.cachix.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
            auto-optimise-store = true;
            use-xdg-base-directories = true;
            # root is always trusted by nix daemon.
            # Per-user entries are added via trustedUsers in defaults.nix.
            http-connections = 50;
            max-substitution-jobs = 128;
            fallback = true; # build locally if a cached NAR is advertised but missing
          };
        };
      };
  };
}
