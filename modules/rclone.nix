{ ... }:
{
  den.aspects.rclone = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.rclone ];

        systemd.services.rclone-gdrive-mount = {
          description = "Mount Google Drive using rclone";
          wantedBy = [ "multi-user.target" ];
          after = [
            "network-online.target"
            "sops-nix.service"
          ];
          requires = [ "network-online.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStartPre = "/run/current-system/sw/bin/mkdir -p /home/deus/google-drive/";
            ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/deus/.config/rclone/rclone.conf --vfs-cache-mode full gdrive: /home/deus/google-drive/";
            ExecStop = "/run/current-system/sw/bin/fusermount -u /home/deus/google-drive/";
            Restart = "on-failure";
            RestartSec = "10s";
            User = "deus";
            Group = "users";
            Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          };
        };
      };

    homeManager =
      { config, ... }:
      {
        sops.secrets.rclone_conf = {
          sopsFile = ../secrets/rclone.yaml;
          path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
        };
      };
  };
}
