# SSH service and host key management.
# sopsFile:     host key (ssh_host_ed25519_key) — per-machine, placed at /etc/ssh/
# userSopsFile: user identity key (ssh_user_ed25519_key) — shared across hosts, placed at ~/.ssh/id_ed25519
# If either is null (default), that key is not managed by sops.
{ lib, ... }:
{
  den.aspects.ssh =
    {
      sopsFile ? null,
      userSopsFile ? null,
    }:
    let
      sopsManaged = sopsFile != null;
      userSopsManaged = userSopsFile != null;
    in
    {
      nixos = _: {
        services.openssh = {
          enable = true;
          hostKeys = lib.mkIf sopsManaged [ ];
        };

        sops.secrets = lib.mkIf sopsManaged {
          ssh_host_ed25519_key = {
            inherit sopsFile;
            path = "/etc/ssh/ssh_host_ed25519_key";
            owner = "root";
            group = "root";
            mode = "0600";
          };
        };
      };

      homeManager =
        { config, ... }:
        {
          sops.secrets = lib.mkIf userSopsManaged {
            ssh_user_ed25519_key = {
              sopsFile = userSopsFile;
              path = "${config.home.homeDirectory}/.ssh/id_ed25519";
              mode = "0600";
            };
          };
        };
    };
}
