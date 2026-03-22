# SSH service and host/user key management.
# Host key (ssh_host_ed25519_key): sourced from host.sopsFile → /etc/ssh/
# User key (ssh_user_ed25519_key): sourced from user.sopsFile → ~/.ssh/id_ed25519
# sopsFile paths are set explicitly as freeform attributes in hosts.nix.
# Both blocks use perUser so they fire at ctx.user {host, user} —
# nixos config from perUser still flows to the NixOS system.
{ lib, den, ... }:
{
  den.aspects.ssh = {
    nixos.services.openssh.enable = true;

    includes = [
      (den.lib.perUser (
        { host, ... }:
        let
          sopsFile = host.sopsFile or null;
          managed = sopsFile != null && builtins.pathExists sopsFile;
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
          sopsFile = user.sopsFile or null;
          managed = sopsFile != null && builtins.pathExists sopsFile;
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
