# SSH service and user key management.
# User key (ssh_user_ed25519_key): sourced from secrets/<username>.yaml → ~/.ssh/id_ed25519
# Placed via system-level sops (NixOS activation) — reliable on every boot for all users.
{ den, ... }:
let
  inherit (den.lib) perUser;

  secrets = ../../secrets;

  userKey =
    { user, ... }:
    let
      sopsFile = "${secrets}/${user.userName}.yaml";
      managed = builtins.pathExists sopsFile;
    in
    {
      nixos =
        { lib, ... }:
        lib.mkIf managed {
          systemd.tmpfiles.rules = [
            "d /home/${user.userName}/.ssh 0700 ${user.userName} users -"
          ];
          sops.secrets."ssh-${user.userName}" = {
            inherit sopsFile;
            key = "ssh_user_ed25519_key";
            path = "/home/${user.userName}/.ssh/id_ed25519";
            owner = user.userName;
            mode = "0600";
          };
        };
    };
in
{
  den.aspects.ssh = {
    nixos.services.openssh.enable = true;
    includes = [
      (perUser userKey)
    ];
  };
}
