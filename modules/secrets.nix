{inputs, ...}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    nixos = {...}: {
      imports = [inputs.sops-nix.nixosModules.sops];

      sops = {
        defaultSopsFile = ../secrets/thinkpad.yaml;
        age.keyFile = "/var/lib/sops/age/keys.txt";

        secrets = {
          ssh_host_ed25519_key = {
            path = "/etc/ssh/ssh_host_ed25519_key";
            owner = "root";
            group = "root";
            mode = "0600";
          };
          ssh_host_rsa_key = {
            path = "/etc/ssh/ssh_host_rsa_key";
            owner = "root";
            group = "root";
            mode = "0600";
          };
        };
      };

      # Prevent openssh from auto-generating keys (we provide them via sops)
      services.openssh.hostKeys = [];
    };

    homeManager = {config, ...}: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      sops = {
        defaultSopsFile = ../secrets/common.yaml;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

        secrets.rclone_conf = {
          path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
        };
      };
    };
  };
}
