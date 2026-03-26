# Secrets Management (sops-nix)

Secrets are encrypted with [sops](https://github.com/getsops/sops) using [age](https://github.com/FiloSottile/age) keys and decrypted at activation time by [sops-nix](https://github.com/Mic92/sops-nix).

## How it works

Each host has a standalone age key that never enters the repo. sops-nix uses it at activation time to decrypt secrets into the correct paths with proper ownership/permissions.

### Asymmetric encryption — why you can encrypt for all hosts from one machine

age (and sops by extension) uses **asymmetric encryption**. Every key pair has two halves:

- **Public key** (`age1...`) — safe to share, stored in `.sops.yaml`. Used to *encrypt*.
- **Private key** — stays on the machine, never committed. Used to *decrypt*.

When sops creates or edits a file, it:
1. Generates a one-time random **data key** and encrypts the file contents with it.
2. Encrypts that data key once per recipient using each recipient's **public key**.
3. Stores all encrypted copies of the data key in the file header.

Because encrypting only needs the public key (just a string in `.sops.yaml`), you can encrypt for thinkpad, personal, and workstation simultaneously from any machine — even one that holds none of their private keys. Each host then decrypts using its own private key to recover the data key and read the file.

This is why `secrets/common.yaml` is accessible to all three hosts even though it was created on thinkpad.

The age key lives in **two locations** because NixOS-level and home-manager-level services run as different users:

| Path | Owner | Used by |
|---|---|---|
| `/var/lib/sops/age/keys.txt` | `root:root` (0600) | NixOS-level sops-nix (runs as root) |
| `~/.config/sops/age/keys.txt` | `deus:users` (0600) | Home-manager sops-nix (runs as user) |

Both files contain the **same key**. The duplication is necessary because the home-manager sops-nix user service cannot read root-owned files.

- **NixOS-level secrets** (SSH host keys) are decrypted by the system `sops-nix` service on boot
- **Home-manager-level secrets** (rclone.conf) are decrypted by the home-manager `sops-nix` user service on login

## Files

| File | Scope | Recipients | Contents |
|---|---|---|---|
| `thinkpad.yaml` | Per-host | thinkpad | SSH host keys |
| `personal.yaml` | Per-host | personal | SSH host keys |
| `workstation.yaml` | Per-host | workstation | SSH host keys |
| `common.yaml` | All hosts | thinkpad, personal, workstation | Shared system secrets (GitHub token, etc.) |
| `deus.yaml` | User | thinkpad, personal, workstation | SSH user keys for `deus` |
| `soumya.yaml` | User | thinkpad, workstation | SSH user keys for `soumya` |
| `rclone.yaml` | Shared | thinkpad, personal, rclone | rclone configuration |
| `../.sops.yaml` | Repo root | — | Age key recipients and creation rules |

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
