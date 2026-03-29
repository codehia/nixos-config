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
