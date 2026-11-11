{ inputs, ... }:
let
  # Login password per user, from secrets/<user>.yaml. Host-side include: den fans a
  # `{ user, ... }` function out once per user on the host and lands its nixos there.
  userPassword =
    { user, ... }:
    {
      nixos =
        { config, ... }:
        {
          sops.secrets."${user.userName}_password" = {
            sopsFile = ../../secrets/${user.userName}.yaml;
            key = "user_password";
            neededForUsers = true;
          };
          users.users.${user.userName}.hashedPasswordFile =
            config.sops.secrets."${user.userName}_password".path;
        };
    };
in
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Placed on hosts (system/base.nix) for the nixos part and on users (base-user.nix)
  # for the homeManager part; each scope delivers only its own classes.
  den.aspects.secrets = {
    includes = [ userPassword ];

    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };

        environment.systemPackages = with pkgs; [
          age
          ssh-to-age
          sops
        ];
      };

    homeManager =
      { config, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops = {
          age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
        };
      };
  };
}
