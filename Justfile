# just is a command runner, Justfile is very similar to Makefile, but simpler.

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

install:
	#!/usr/bin/env bash
	set -euo pipefail
	HOSTNAME=$(hostname -s)
	SYSTEM_KEY="/var/lib/sops/age/keys.txt"
	USER_KEY="${HOME}/.config/sops/age/keys.txt"
	ENCRYPTED_KEY="secrets/${HOSTNAME}-age-key.age"

	if [[ -f "${ENCRYPTED_KEY}" ]] && [[ ! -f "${SYSTEM_KEY}" ]]; then
	  echo "==> Age key missing. Decrypting ${ENCRYPTED_KEY} (enter passphrase):"
	  TMPKEY=$(mktemp)
	  trap "rm -f ${TMPKEY}" EXIT
	  age --decrypt "${ENCRYPTED_KEY}" > "${TMPKEY}"
	  sudo mkdir -p "$(dirname "${SYSTEM_KEY}")"
	  sudo install -m 600 -o root -g root "${TMPKEY}" "${SYSTEM_KEY}"
	  mkdir -p "$(dirname "${USER_KEY}")"
	  install -m 600 "${TMPKEY}" "${USER_KEY}"
	  echo "==> Age key placed at ${SYSTEM_KEY} and ${USER_KEY}."
	fi

	if [[ -f "${SYSTEM_KEY}" ]] && [[ ! -f "${USER_KEY}" ]]; then
	  echo "==> Syncing user age key from system key..."
	  mkdir -p "$(dirname "${USER_KEY}")"
	  sudo install -m 600 -o "$(id -u)" -g "$(id -g)" "${SYSTEM_KEY}" "${USER_KEY}"
	  echo "==> User age key placed at ${USER_KEY}."
	fi

	nixos-rebuild switch --flake . --sudo

debug:
	nixos-rebuild switch --flake . --sudo --show-trace --verbose

write-flake:
	nix run ".#write-flake"

up:
	nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
	nix flake update $(i)

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
