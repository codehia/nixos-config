# SSH service and host key management.
# Host key (ssh_host_ed25519_key) sourced from secrets/<hostname>.yaml → /etc/ssh/
# User key (ssh_user_ed25519_key) sourced from secrets/<username>.yaml → ~/.ssh/id_ed25519
# Paths are derived by convention. If the secrets file doesn't exist for a host/user,
# that key is silently unmanaged (same behaviour as the old sopsFile ? null default).
{
  lib,
  den,
  self,
  ...
}:
{
  den.aspects.ssh = {
    nixos.services.openssh.enable = true;

    includes = [
      (den.lib.perHost (
        { host }:
        let
          sopsFile = "${self}/secrets/${host.hostName}.yaml";
          managed = builtins.pathExists sopsFile;
        in
        {
          nixos =
            { lib, ... }:
            lib.mkIf managed {
              # Disable auto-generated host keys — sops places the real one below.
              services.openssh.hostKeys = [ ];
              sops.secrets.ssh_host_ed25519_key = {
                inherit sopsFile;
                path = "/etc/ssh/ssh_host_ed25519_key";
                owner = "root";
                group = "root";
                mode = "0600";
              };
            };
        }
      ))

      (den.lib.perUser (
        { user, ... }:
        let
          sopsFile = "${self}/secrets/${user.userName}.yaml";
          managed = builtins.pathExists sopsFile;
        in
        {
          homeManager =
            { config, lib, ... }:
            lib.mkIf managed {
              sops.secrets.ssh_user_ed25519_key = {
                inherit sopsFile;
                path = "${config.home.homeDirectory}/.ssh/id_ed25519";
                mode = "0600";
              };
            };
        }
      ))
    ];
  };
}
