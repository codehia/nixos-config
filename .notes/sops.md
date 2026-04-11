# SOPS, Age, and sops-nix

## What is SOPS?

[SOPS](https://github.com/getsops/sops) (Secrets OPerationS) is a secrets management tool by Mozilla. It encrypts the **values** in structured files (YAML, JSON, ENV, INI) while leaving **keys** in plaintext. This means you can:

- Commit encrypted secrets into a git repo safely
- See which secrets exist (the keys are plaintext) without being able to read them
- Track changes to secret structure in diffs

A SOPS-encrypted YAML file looks like:

```yaml
github_token: ENC[AES256_GCM,data:abc123...,iv:...,tag:...,type:str]
sops:
    age:
        - recipient: age14erpwm...
          enc: |
              -----BEGIN AGE ENCRYPTED FILE-----
              ...
    lastmodified: "2024-01-01T00:00:00Z"
    ...
```

The `sops:` block is metadata SOPS appends to the file — it stores the encrypted data key (one per recipient), MAC, and version info.

## What is age?

[age](https://github.com/FiloSottile/age) is a simple, modern encryption tool. It replaces GPG for SOPS in most modern setups. Key properties:

- **Keypair**: a private key (`AGE-SECRET-KEY-1...`) and a public key (`age1...`)
- **Generate**: `age-keygen -o keys.txt` — writes the private key to `keys.txt`, prints the public key
- **Encrypt**: `age -r age1<pubkey> file.txt > file.txt.age`
- **Decrypt**: `age --decrypt -i keys.txt file.txt.age`
- Keys are short strings, no keyring, no daemon, no web of trust

age can also derive keys from SSH keys — `ssh-to-age` converts an ed25519 SSH public key to an age public key. sops-nix uses this to let the SSH host key double as the sops decryption key.

## How SOPS + age work together

```
Encryption (write time):
  plaintext value
      ↓
  SOPS generates random AES-256 data key
      ↓
  AES-256-GCM encrypts each value → ENC[...] ciphertext stored in file
      ↓
  data key is encrypted with each age recipient's public key
      ↓
  encrypted data keys stored in sops: metadata block

Decryption (read time):
  age private key (derived from SSH host key)
      ↓
  decrypts the data key from sops: metadata block
      ↓
  data key decrypts the ENC[...] values → plaintext
```

Multiple recipients means multiple machines can decrypt the same file independently — each has its own copy of the encrypted data key, decryptable only with its own private key.

## .sops.yaml — Encryption Rules

The `.sops.yaml` file at the repo root defines which age public keys are recipients for which files. The age public keys here are derived from each machine's SSH host key via `ssh-to-age`:

```yaml
keys:
  - &thinkpad    age14erpwmsl6vsnl5vx4zkqqkcfyfrgv5yprzwxjp4xazxjntvg532sdmsp3r
  - &personal    age14tcn43rzydp8t6afujxlzy0xwh9ctftvz43e7pez43qhdmgqmc6qyrywle
  - &workstation age1w5yred8ne457e0xhfcyvqwdy0ucvs5cywht3fdyn0tyt2gfhkg8qvd3dpy
  - &rclone      age1kg0cjadgrycgx3s0qufp9c0xlhmc3ectsvmtt5k79lwsyh3x7q9qj3m3tp

creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age: [*thinkpad, *personal, *workstation]

  - path_regex: secrets/rclone\.yaml$
    key_groups:
      - age: [*rclone, *personal, *thinkpad]
  # ... etc
```

YAML anchors (`&name`) define the keys once; aliases (`*name`) reuse them.

### Secret files and their recipients

| File | Recipients | Contents |
|------|-----------|----------|
| `secrets/common.yaml` | thinkpad, personal, workstation | `github_token` |
| `secrets/deus.yaml` | thinkpad, personal, workstation | `ssh_user_ed25519_key` |
| `secrets/soumya.yaml` | thinkpad, workstation | `user_password`, `ssh_user_ed25519_key` |
| `secrets/rclone.yaml` | rclone, personal, thinkpad | `rclone_conf` |

## What is sops-nix?

[sops-nix](https://github.com/Mic92/sops-nix) is a NixOS/home-manager module that integrates SOPS into the activation process. It:

1. Reads `sops.secrets.*` declarations from your NixOS/HM config
2. At activation time (boot / `nixos-rebuild switch` / HM activation), decrypts the specified secrets
3. Places them as files at the declared paths with correct ownership and permissions
4. Secrets live in `/run/secrets/` by default (tmpfs, cleared on reboot), unless `path` is explicitly set

The key insight: **secrets are never in the Nix store** (which is world-readable). They are decrypted only at activation time into runtime paths.

## How It Ties Into This Config

### The secrets aspect — `modules/aspects/secrets.nix`

```nix
{ inputs, ... }:
{
  den.aspects.secrets = {
    nixos = { pkgs, lib, ... }: {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # cleanup script removes stale symlinks from old sops-managed SSH host keys
      system.activationScripts.cleanup-sops-ssh-hostkey = lib.stringAfter [ ] ''...'';
      system.activationScripts.setupSecrets.deps = [ "cleanup-sops-ssh-hostkey" ];
    };

    homeManager = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
  };
}
```

NixOS-level sops decrypts using the SSH host key (auto-generated by NixOS on first boot). HM sops decrypts using the user's SSH key (which is itself placed by NixOS sops on boot). No manual age key file management.

### SSH host keys

NixOS manages SSH host keys directly — `sshd-keygen.service` generates a real key file at `/etc/ssh/ssh_host_ed25519_key` on first boot. sops-nix then uses that same key as its decryption identity.

### User SSH keys — `modules/aspects/ssh.nix`

```nix
userKey = { user, ... }:
  let
    sopsFile = "${secrets}/${user.userName}.yaml";
    managed = builtins.pathExists sopsFile;
  in {
    nixos = { lib, ... }: lib.mkIf managed {
      systemd.tmpfiles.rules = [
        "d /home/${user.userName}/.ssh 0700 ${user.userName} users -"
      ];
      sops.secrets."ssh-${user.userName}" = {
        inherit sopsFile;
        key = "ssh_user_ed25519_key";
        path = "/home/${user.userName}/.ssh/id_ed25519";
        owner = user.userName;
        mode = "0600";
      };
    };
  };
```

User SSH keys are placed via **NixOS-level** sops (not home-manager), so they're available on every boot, not just after user login. Secret names are unique per user (`ssh-<username>`) to avoid namespace collisions on multi-user hosts.

### GitHub token — `modules/aspects/nix-config.nix`

```nix
sops.secrets.github_token = {
  sopsFile = ../../secrets/common.yaml;
};

systemd.services.nix-daemon.serviceConfig.EnvironmentFiles = [
  config.sops.secrets.github_token.path
];
```

### Rclone — `modules/aspects/rclone.nix`

```nix
sops.secrets.rclone_conf = {
  sopsFile = ../../secrets/rclone.yaml;
  path = "${home}/.config/rclone/rclone.conf";
};
```

## Activation Flow (End to End)

```
Boot / nixos-rebuild switch:
  sops-nix NixOS activation
    derives age key from /etc/ssh/ssh_host_ed25519_key
    decrypts secrets/common.yaml
    → writes /run/secrets/github_token (root:root 0400)
    decrypts secrets/soumya.yaml + secrets/deus.yaml
    → writes /home/soumya/.ssh/id_ed25519 (soumya 0600)
    → writes /home/deus/.ssh/id_ed25519 (deus 0600)
    decrypts secrets/soumya.yaml (user_password)
    → writes /run/secrets/soumya_password (root 0400)
  OpenSSH starts, uses /etc/ssh/ssh_host_ed25519_key
  nix-daemon starts, reads EnvironmentFile → has GITHUB_TOKEN

Login / home-manager switch:
  sops-nix HM activation
    derives age key from ~/.ssh/id_ed25519
    decrypts secrets/rclone.yaml
    → writes ~/.config/rclone/rclone.conf (user 0600)
  rclone-gdrive-mount.service starts, mounts Google Drive
```

## Adding a New Host

1. Install NixOS and boot — SSH host key auto-generated
2. `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age` — get the age public key
3. Add to `.sops.yaml` with a new anchor
4. `sops updatekeys secrets/common.yaml secrets/deus.yaml` — re-encrypt for new host
5. `just install` on the new host — decryption works automatically, no key bootstrap

## Common Operations

```bash
# Edit a secrets file (opens decrypted in $EDITOR, re-encrypts on save)
sops secrets/deus.yaml

# Or without sops in PATH
nix shell nixpkgs#sops -c sops secrets/deus.yaml

# Add a new host's key to an existing file's recipients
sops updatekeys secrets/common.yaml

# Get a machine's age public key from its SSH host key
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```
