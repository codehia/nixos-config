# Secrets and SSH

## How it works

Secrets are encrypted with [sops](https://github.com/getsops/sops) + age keys, and
decrypted at activation time by sops-nix. `.sops.yaml` says which age keys can decrypt
which files.

Each host has one age key in two places (same file, two paths):

| Path | Owner | Used for |
|------|-------|----------|
| `/var/lib/sops/age/keys.txt` | root | SSH host keys, system secrets |
| `~/.config/sops/age/keys.txt` | user | SSH user keys, rclone.conf |

`just install` auto-syncs the user copy from the system copy if it's missing.

---

## Add a user SSH key

`ssh.nix` automatically places a user's SSH key at `~/.ssh/id_ed25519` if
`secrets/<username>.yaml` exists.

**1. Add a creation rule to `.sops.yaml`**

```yaml
creation_rules:
  - path_regex: secrets/soumya\.yaml$
    key_groups:
      - age:
          - *workstation
```

**2. Generate an SSH key**

```bash
ssh-keygen -t ed25519 -f /tmp/soumya_key -N "" -C "soumya@workstation"
cat /tmp/soumya_key    # copy this
```

**3. Create the sops file**

```bash
sops secrets/soumya.yaml
```

Paste into the editor:
```yaml
ssh_user_ed25519_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste the private key here>
    -----END OPENSSH PRIVATE KEY-----
```

**4. Clean up and apply**

```bash
rm /tmp/soumya_key /tmp/soumya_key.pub
git add secrets/soumya.yaml
just install
```

---

## Edit an existing secrets file

```bash
sops secrets/deus.yaml    # decrypts, opens in $EDITOR, re-encrypts on save
```

---

## Add a new secret and use it in config

```nix
# Home-manager secret
homeManager = { config, ... }: {
  sops.secrets.github_token = {
    sopsFile = ../../secrets/deus.yaml;
    path = "${config.home.homeDirectory}/.config/gh/token";
    mode = "0600";
  };
};

# System secret
nixos.sops.secrets.service_key = {
  sopsFile = ../../secrets/workstation.yaml;
  path = "/etc/myservice/key";
  owner = "myservice";
  mode = "0400";
};
```

---

## Re-encrypt after adding a new key recipient

```bash
# After updating .sops.yaml to add a new age key:
sops updatekeys secrets/rclone.yaml
```

---

## Restore the age key on a fresh install

```bash
age --decrypt secrets/<hostname>-age-key.age > /tmp/keys.txt

sudo mkdir -p /var/lib/sops/age
sudo install -m 600 -o root -g root /tmp/keys.txt /var/lib/sops/age/keys.txt

mkdir -p ~/.config/sops/age
install -m 600 /tmp/keys.txt ~/.config/sops/age/keys.txt

rm /tmp/keys.txt
just install
```
