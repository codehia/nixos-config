# Deploy configuration using nixos-unified
deploy:
  nix run .#activate

# Deploy specific host (e.g., just deploy-host thinkpad)
deploy-host host:
  nix run .#activate {{host}}

# Legacy deploy using nixos-rebuild
install:
  nixos-rebuild switch --flake . --use-remote-sudo

debug:
  nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose

up:
  nix flake update

# Update specific input
# usage: just upp i=home-manager
upp i:
  nix flake update {{i}}

# Update flake inputs using nixos-unified
update:
  nix run .#update

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old
