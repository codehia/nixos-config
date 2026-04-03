# SSH service and host/user key management.
# Host key (ssh_host_ed25519_key): sourced from secrets/<hostname>.yaml → /etc/ssh/
# User key (ssh_user_ed25519_key): sourced from secrets/<username>.yaml → ~/.ssh/id_ed25519
# Paths are derived by convention — no freeform sopsFile attr needed.
{ den, ... }:
let
  inherit (den.lib) perUser;
  inherit (den.lib) perHost;

  secrets = ../../secrets;

  hostKey =
    { host, ... }:
    let
      sopsFile = "${secrets}/${host.hostName}.yaml";
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
            type = "ed25519";
            owner = "root";
            group = "root";
            mode = "0600";
          };
        };
    };

  userKey =
    { user, ... }:
    let
      sopsFile = "${secrets}/${user.userName}.yaml";
      managed = builtins.pathExists sopsFile;
    in
    {
      homeManager =
        {
          config,
          lib,
          ...
        }:
        lib.mkIf managed {
          sops.secrets.ssh_user_ed25519_key = {
            inherit sopsFile;
            path = "${config.home.homeDirectory}/.ssh/id_ed25519";
            mode = "0600";
          };
        };
    };
in
{
  den.aspects.ssh = {
    nixos.services.openssh.enable = true;
    includes = [
      (perHost hostKey)
      (perUser userKey)
    ];
  };
}
