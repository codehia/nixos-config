{
  den.aspects.rclone = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.rclone ];
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        home = config.home.homeDirectory;
      in
      {
        sops.secrets.rclone_conf = {
          sopsFile = ../../secrets/rclone.yaml;
          path = "${home}/.config/rclone/rclone.conf";
        };

        systemd.user.services.rclone-gdrive-mount = {
          Unit = {
            Description = "Mount Google Drive using rclone";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "simple";
            ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${home}/google-drive";
            ExecStart = "${pkgs.rclone}/bin/rclone mount --config ${home}/.config/rclone/rclone.conf --vfs-cache-mode full gdrive: ${home}/google-drive/";
            ExecStop = "/run/current-system/sw/bin/fusermount -u ${home}/google-drive/";
            Restart = "on-failure";
            RestartSec = "10s";
            Environment = "PATH=/run/wrappers/bin:/run/current-system/sw/bin";
          };

          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
  };
}
