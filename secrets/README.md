# Secrets Management (sops-nix)

Secrets are encrypted with [sops](https://github.com/getsops/sops) using [age](https://github.com/FiloSottile/age) keys and decrypted at activation time by [sops-nix](https://github.com/Mic92/sops-nix).

## How it works

Each host has a standalone age key that never enters the repo. sops-nix uses it at activation time to decrypt secrets into the correct paths with proper ownership/permissions.

The age key lives in **two locations** because NixOS-level and home-manager-level services run as different users:

| Path | Owner | Used by |
|---|---|---|
| `/var/lib/sops/age/keys.txt` | `root:root` (0600) | NixOS-level sops-nix (runs as root) |
| `~/.config/sops/age/keys.txt` | `deus:users` (0600) | Home-manager sops-nix (runs as user) |

Both files contain the **same key**. The duplication is necessary because the home-manager sops-nix user service cannot read root-owned files.

- **NixOS-level secrets** (SSH host keys) are decrypted by the system `sops-nix` service on boot
- **Home-manager-level secrets** (rclone.conf) are decrypted by the home-manager `sops-nix` user service on login

## Files

| File | Scope | Contents |
|---|---|---|
| `thinkpad.yaml` | Per-host | SSH host keys (ed25519, RSA) |
| `common.yaml` | Shared | rclone.conf |
| `../.sops.yaml` | Repo root | Age key recipients and creation rules |

## Editing secrets

```bash
# Requires sops and the age key at ~/.config/sops/age/keys.txt
sops secrets/thinkpad.yaml
sops secrets/common.yaml

# Or via nix-shell if sops isn't installed
nix-shell -p sops --run "sops secrets/thinkpad.yaml"
```

## Adding a new host

1. Generate an age key on the new host and copy it to both locations:
   ```bash
   sudo mkdir -p /var/lib/sops/age
   sudo age-keygen -o /var/lib/sops/age/keys.txt

   mkdir -p ~/.config/sops/age
   sudo cp /var/lib/sops/age/keys.txt ~/.config/sops/age/keys.txt
   sudo chown "$USER:$(id -gn)" ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```
2. Add the public key to `.sops.yaml` with a YAML anchor:
   ```yaml
   keys:
     - &thinkpad age1...
     - &newhost age1...
   ```
3. Create a host-specific secrets file:
   ```bash
   sops secrets/newhost.yaml
   # Add: ssh_host_ed25519_key, ssh_host_rsa_key
   ```
4. Add the new host's key to `common.yaml`'s creation rule in `.sops.yaml`, then re-encrypt:
   ```bash
   sops updatekeys secrets/common.yaml
   ```
5. Update `modules/secrets.nix` to select the correct `defaultSopsFile` per host (e.g. using `config.networking.hostName`).

## Reinstalling a host

Before deploying the config, restore the age key to **both** locations:

```bash
# 1. System-level key (for NixOS sops-nix service)
sudo mkdir -p /var/lib/sops/age
sudo cp /path/to/backup/keys.txt /var/lib/sops/age/keys.txt
sudo chmod 600 /var/lib/sops/age/keys.txt

# 2. User-level key (for home-manager sops-nix service)
mkdir -p ~/.config/sops/age
cp /path/to/backup/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Then deploy (`just install`). sops-nix will decrypt SSH host keys and rclone.conf automatically. The host will keep the same SSH fingerprint.

> **If you only restore the system key**, the NixOS-level secrets will work but home-manager activation will fail with `permission denied` on `/var/lib/sops/age/keys.txt` because the user service cannot read root-owned files.

## Backing up the age key

The age key at `/var/lib/sops/age/keys.txt` is the **only** way to decrypt secrets. Back it up securely (password manager, encrypted USB, etc.). Losing it means re-encrypting all secrets with a new key.
