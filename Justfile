# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Always point nh at the flake in this directory, regardless of where it's cloned.
export NH_FLAKE := justfile_directory()

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

	nh os switch

# Build and activate temporarily (no boot entry)
test:
	nh os test

# Build and set boot default without activating
boot:
	nh os boot

# Dry run — show what would change without applying
dry:
	nh os switch -n

# Apply with trace for debugging
debug:
	nh os switch -- --show-trace --verbose

write-flake:
	nix run ".#write-flake"

# Update all flake inputs and rebuild. To update without rebuilding: nix flake update
up:
	nh os switch -u

# Update a single flake input and rebuild: just upp i=home-manager
# To update without rebuilding: nix flake update <input>
upp:
	nh os switch -U $(i)

# Show generation history
history:
	nh os info

repl:
	nh os repl

# Garbage collect — remove old generations and unused store entries
clean:
	nh clean all
