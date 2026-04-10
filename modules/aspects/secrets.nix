{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    nixos =
      { pkgs, lib, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops = {
          age.keyFile = "/var/lib/sops/age/keys.txt";
        };

        # Remove dangling SSH host key symlinks left by old sops management.
        # After removal, NixOS openssh module generates real persistent key files.
        system.activationScripts.cleanup-sops-ssh-hostkey = lib.stringAfter [ ] ''
          for key in /etc/ssh/ssh_host_*_key; do
            if [ -L "$key" ] && [ ! -e "$key" ]; then
              rm -f "$key"
            fi
          done
        '';

        # Ensure dangling symlinks are cleaned before sops runs.
        system.activationScripts.setupSecrets.deps = [ "cleanup-sops-ssh-hostkey" ];

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
          age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };
  };
}
