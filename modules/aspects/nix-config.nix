{ den, ... }:
{
  den.aspects.nix-config = {
    nixos =
      { pkgs, config, ... }:
      {
        sops.secrets.github_token = {
          sopsFile = ../../secrets/common.yaml;
        };

        systemd.services.nix-daemon.serviceConfig.EnvironmentFiles = [
          config.sops.secrets.github_token.path
        ];

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
              "https://hyprland.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
