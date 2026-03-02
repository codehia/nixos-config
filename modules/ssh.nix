# SSH service and host key management.
# If sopsFile is provided, host keys are restored from sops and auto-generation is disabled.
# If sopsFile is null (default), openssh generates its own host keys normally.
{ lib, ... }:
{
  den.aspects.ssh =
    {
      sopsFile ? null,
    }:
    let
      sopsManaged = sopsFile != null;
    in
    {
      nixos =
        { ... }:
        {
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
            ssh_host_rsa_key = {
              inherit sopsFile;
              path = "/etc/ssh/ssh_host_rsa_key";
              owner = "root";
              group = "root";
              mode = "0600";
            };
          };
        };
    };
}
