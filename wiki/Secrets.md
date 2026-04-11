# Secrets and SSH

## How it works

Secrets are encrypted with [sops](https://github.com/getsops/sops) + age keys, and decrypted at activation time by sops-nix. `.sops.yaml` says which age keys can decrypt which files.

Each host decrypts secrets using its **SSH host key** — no separate age key file to manage:

| Layer | Key source | When it runs |
|-------|-----------|--------------|
| NixOS (`sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"]`) | SSH host key | Every boot (system activation) |
| Home-manager (`sops.age.sshKeyPaths = ["~/.ssh/id_ed25519"]`) | User SSH key | On login (HM activation) |

The age public keys in `.sops.yaml` are derived from each machine's SSH host key via `ssh-to-age`. On a fresh install, NixOS generates the SSH host key on first boot — sops-nix picks it up automatically with zero manual setup.

---

## Add a user SSH key

`ssh.nix` automatically places a user's SSH key at `~/.ssh/id_ed25519` if `secrets/<username>.yaml` exists. Placement happens via NixOS-level sops on every boot.

**1. Add a creation rule to `.sops.yaml`**

```yaml
creation_rules:
  - path_regex: secrets/soumya\.yaml$
    key_groups:
      - age:
          - *workstation
          - *thinkpad   # add all hosts the user lives on
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

**4. Add the public key to the user's NixOS config**

```nix
users.users.soumya.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... soumya@workstation"
];
```

**5. Clean up and apply**

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
# System secret (placed by NixOS-level sops, available on every boot)
nixos.sops.secrets.my_token = {
  sopsFile = ../../secrets/common.yaml;
  owner = "myservice";
  mode = "0400";
};

# Home-manager secret (placed by HM sops, available after login)
homeManager = { config, ... }: {
  sops.secrets.rclone_conf = {
    sopsFile = ../../secrets/rclone.yaml;
    path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
  };
};
```

---

## Re-encrypt after adding a new key recipient

```bash
# After updating .sops.yaml to add a new age key:
sops updatekeys secrets/common.yaml
```

---

## Adding a new host

1. Install NixOS and boot — SSH host key is auto-generated on first boot
2. Get the age public key: `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age`
3. Add it to `.sops.yaml` with a new YAML anchor
4. `sops updatekeys` on any shared files (common.yaml, deus.yaml, etc.)
5. `just install` on the new host — no age key bootstrap needed
