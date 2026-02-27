#!/usr/bin/env bash
# NixOS installer for codehia/nixos-config (dendritic pattern)
#
# Fetch and run:
#   bash <(curl -fsSL https://raw.githubusercontent.com/codehia/nixos-config/master/install.sh)
#
# Or download first (recommended):
#   curl -fsSL https://raw.githubusercontent.com/codehia/nixos-config/master/install.sh -o install.sh
#   bash install.sh
#
# Uses disko-install to handle partitioning + NixOS installation in one step.

set -euo pipefail

# -- Config --
REPO="github:codehia/nixos-config"
BRANCH="master"

# -- Helpers --
info() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }
die()  { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

# Read from /dev/tty so this works when piped through curl | bash
ask() {
  local prompt="$1" var="$2" default="${3:-}"
  if [[ -n "$default" ]]; then
    printf '%s [%s]: ' "$prompt" "$default" >/dev/tty
  else
    printf '%s: ' "$prompt" >/dev/tty
  fi
  read -r "$var" </dev/tty
  if [[ -z "${!var}" && -n "$default" ]]; then
    printf -v "$var" '%s' "$default"
  fi
}

confirm() {
  local prompt="${1:-Continue?}"
  printf '\n%s [y/N] ' "$prompt" >/dev/tty
  local ans
  read -r ans </dev/tty
  [[ "${ans,,}" == "y" ]]
}

# -- Preflight --
[[ $EUID -eq 0 ]] || die "Run as root. Try: sudo bash install.sh"

command -v nix &>/dev/null || die "nix not found. Boot from a NixOS installer ISO."

# -- Host selection --
info "Hosts"
echo "  thinkpad  — ThinkPad laptop (1 disk)"
echo "  personal  — Desktop (2 disks: fast main + slow archive)"
echo ""
ask "Host" HOST

case "$HOST" in
  thinkpad|personal) ;;
  *) die "Unknown host: '$HOST'. Valid hosts: thinkpad, personal" ;;
esac

# -- Disk selection --
info "Block devices"
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL
echo ""

case "$HOST" in
  thinkpad)
    warn "All data on the selected disk will be ERASED."
    ask "Main disk (e.g. /dev/nvme0n1)" MAIN_DISK
    [[ -b "$MAIN_DISK" ]] || die "Not a block device: $MAIN_DISK"
    DISK_ARGS=(--disk main "$MAIN_DISK")
    DISK_SUMMARY="  main  →  $MAIN_DISK"
    ;;

  personal)
    warn "All data on both selected disks will be ERASED."
    ask "Fast disk — system/home/nix (e.g. /dev/nvme0n1)" MAIN_DISK
    ask "Slow disk — archive/backups  (e.g. /dev/nvme1n1)" SLOW_DISK
    [[ -b "$MAIN_DISK" ]] || die "Not a block device: $MAIN_DISK"
    [[ -b "$SLOW_DISK" ]] || die "Not a block device: $SLOW_DISK"
    [[ "$MAIN_DISK" != "$SLOW_DISK" ]] || die "Fast and slow disks must be different devices"
    DISK_ARGS=(--disk main "$MAIN_DISK" --disk slow "$SLOW_DISK")
    DISK_SUMMARY="  main  →  $MAIN_DISK
  slow  →  $SLOW_DISK"
    ;;
esac

# -- Summary --
info "Install summary"
printf '  Host:   %s\n' "$HOST"
printf '  Flake:  %s/%s#%s\n' "$REPO" "$BRANCH" "$HOST"
printf '  Disks:\n%s\n' "$DISK_SUMMARY"

echo ""
warn "This is DESTRUCTIVE. The disk(s) above will be wiped and repartitioned."
confirm "Proceed with installation?" || { echo "Aborted."; exit 0; }

# -- Install --
info "Running disko-install (this will take a while on first run)"
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest#disko-install -- \
  --flake "${REPO}/${BRANCH}#${HOST}" \
  "${DISK_ARGS[@]}" \
  --write-efi-boot-entries

# -- Post-install --
info "Installation complete"
cat <<'EOF'

Before rebooting, you likely need to set up secrets (sops-nix):

  1. Generate an age key on the new system (or copy an existing one):
       mkdir -p /mnt/home/deus/.config/sops/age
       age-keygen -o /mnt/home/deus/.config/sops/age/keys.txt

  2. Add the new public key to .sops.yaml in the repo and re-encrypt
     any secrets that should be accessible on this host.

  3. Reboot:
       reboot

EOF
