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
        - recipient: age1e7x9jlc...
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

When SOPS uses age, it generates a random data key (AES-256), uses it to encrypt the secret values, then encrypts the data key with each recipient's age public key. Decryption requires the matching age private key.

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
  age private key
      ↓
  decrypts the data key from sops: metadata block
      ↓
  data key decrypts the ENC[...] values → plaintext
```

Multiple recipients means multiple machines can decrypt the same file independently — each has its own copy of the encrypted data key, decryptable only with its own private key.

## .sops.yaml — Encryption Rules

The `.sops.yaml` file at the repo root defines which age public keys are recipients for which files:

```yaml
# .sops.yaml
keys:
  - &thinkpad    age1e7x9jlcpmmhd03xm2amstt90kwjphwklu3wa028v20tauz6r4aeqfdw8gp
  - &personal    age1uu6vj77ea5gtdwxsarvw7rygzrefeg4nl3vam9ddue279a3nhanqvsy8km
  - &workstation age1fjph6rn4nhquuxslks9tt36d8vankcxtwss2cwc96xyllzd67fnsytphfm
  - &rclone      age1kg0cjadgrycgx3s0qufp9c0xlhmc3ectsvmtt5k79lwsyh3x7q9qj3m3tp

creation_rules:
  - path_regex: secrets/thinkpad\.yaml$
    key_groups:
      - age: [*thinkpad]

  - path_regex: secrets/common\.yaml$
    key_groups:
      - age: [*thinkpad, *personal, *workstation]

  - path_regex: secrets/rclone\.yaml$
    key_groups:
      - age: [*rclone, *personal, *thinkpad]
  # ... etc
```

YAML anchors (`&name`) define the keys once; aliases (`*name`) reuse them. When you run `sops secrets/thinkpad.yaml`, SOPS looks up the matching `creation_rules` entry and encrypts the data key for only those recipients — thinkpad cannot decrypt workstation's secrets, for example.

### Secret files and their recipients

| File | Recipients | Contents |
|------|-----------|----------|
| `secrets/thinkpad.yaml` | thinkpad | SSH host keys |
| `secrets/personal.yaml` | personal | SSH host keys |
| `secrets/workstation.yaml` | workstation | SSH host keys |
| `secrets/common.yaml` | thinkpad, personal, workstation | `github_token` |
| `secrets/deus.yaml` | thinkpad, personal, workstation | `ssh_user_ed25519_key` |
| `secrets/soumya.yaml` | thinkpad, workstation | `ssh_user_ed25519_key` |
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
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.secrets = {
    nixos = { ... }: {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.age.keyFile = "/var/lib/sops/age/keys.txt";
    };

    homeManager = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
```

This is a Multi-Context Aspect — it imports the sops-nix modules into both NixOS and home-manager, and points each to the age key at its respective location. The flake input is declared inline here (`flake-file.inputs`) so it's auto-merged by the dendritic pattern.

### Two key locations — why?

NixOS-level services (sshd, nix-daemon) run as `root`. Home-manager activation runs as the user. A file owned `root:root 0600` is unreadable to the user. Both need the same age key to decrypt their respective secrets.

| Path | Owner | Used by |
|------|-------|---------|
| `/var/lib/sops/age/keys.txt` | root:root 0600 | NixOS sops-nix (system activation) |
| `~/.config/sops/age/keys.txt` | deus:users 0600 | HM sops-nix (user activation) |

Both files contain the **same private key**. If you only restore the system key after a reinstall, home-manager activation will fail with `permission denied`.

### SSH host keys — `modules/aspects/ssh.nix`

```nix
hostKey = { host, ... }:
  let
    sopsFile = "${secrets}/${host.hostName}.yaml";
    managed = builtins.pathExists sopsFile;
  in {
    nixos = { lib, ... }: lib.mkIf managed {
      services.openssh.hostKeys = [];   # disable auto-generated keys
      sops.secrets.ssh_host_ed25519_key = {
        inherit sopsFile;
        path = "/etc/ssh/ssh_host_ed25519_key";
        owner = "root"; group = "root"; mode = "0600";
      };
    };
  };
```

The aspect is **conditional** — it only activates if `secrets/<hostname>.yaml` exists (`builtins.pathExists` is pure, evaluated at eval time). This means adding a new host just requires creating the secrets file; nothing else changes.

User SSH keys follow the same pattern at the home-manager level, decrypting to `~/.ssh/id_ed25519`.

### GitHub token — `modules/aspects/nix-config.nix`

```nix
sops.secrets.github_token = {
  sopsFile = ../../secrets/common.yaml;
};

systemd.services.nix-daemon.serviceConfig.EnvironmentFiles = [
  config.sops.secrets.github_token.path
];
```

The secret is decrypted to a file in `/run/secrets/`. That file is passed to nix-daemon as an `EnvironmentFile` — systemd reads it and injects the `GITHUB_TOKEN=...` variable into the daemon's environment, allowing authenticated GitHub access for flake fetching.

### Rclone — `modules/aspects/rclone.nix`

```nix
sops.secrets.rclone_conf = {
  sopsFile = ../../secrets/rclone.yaml;
  path = "${home}/.config/rclone/rclone.conf";
};
```

The decrypted rclone config is placed directly at the standard rclone config path. The `rclone-gdrive-mount` systemd user service then references it by path.

## Activation Flow (End to End)

```
Boot / nixos-rebuild switch:
  sops-nix NixOS activation
    reads /var/lib/sops/age/keys.txt
    decrypts secrets/<hostname>.yaml
    → writes /etc/ssh/ssh_host_ed25519_key (root:root 0600)
    decrypts secrets/common.yaml
    → writes /run/secrets/github_token (root:root 0400)
  OpenSSH starts, uses /etc/ssh/ssh_host_ed25519_key
  nix-daemon starts, reads EnvironmentFile → has GITHUB_TOKEN

Login / home-manager switch:
  sops-nix HM activation
    reads ~/.config/sops/age/keys.txt
    decrypts secrets/<username>.yaml
    → writes ~/.ssh/id_ed25519 (user 0600)
    decrypts secrets/rclone.yaml
    → writes ~/.config/rclone/rclone.conf (user 0600)
  rclone-gdrive-mount.service starts, mounts Google Drive
```

## Creating a Shared Secrets File (readable by multiple hosts)

The key insight: `.sops.yaml` creation rules are applied **by file path**. When you run `sops secrets/foo.yaml`, SOPS looks up which rule matches `secrets/foo.yaml` and encrypts the data key for every recipient in that rule. Each host can then independently decrypt using only its own private key.

**Step 1: Add a creation rule to `.sops.yaml`**

```yaml
creation_rules:
  - path_regex: secrets/myshared\.yaml$
    key_groups:
      - age:
          - *thinkpad
          - *personal
          - *workstation
```

All three age public keys are listed as recipients. SOPS will encrypt one copy of the data key per recipient.

**Step 2: Create (or edit) the file on any one host**

You only need your own age private key to create a new file — SOPS encrypts *to* the recipients' public keys, which are already in `.sops.yaml`. You do not need the other hosts' private keys.

```bash
sops secrets/myshared.yaml
# $EDITOR opens with an empty template; add your secrets:
# my_api_key: supersecret
# On save, SOPS encrypts values and writes 3 encrypted data keys into the sops: block
```

**Step 3: Commit the encrypted file**

The file is safe to commit. Each host has its own encrypted copy of the data key in the `sops:` metadata block. On thinkpad, the thinkpad-encrypted copy is used; on workstation, its own copy is used. Neither can read the other's private key.

**Step 4: Consume the secret in NixOS/HM config**

```nix
sops.secrets.my_api_key = {
  sopsFile = ../../secrets/myshared.yaml;
};
```

sops-nix will decrypt this on each host using whichever key it finds at the configured `age.keyFile` path.

---

**Adding an existing file to more recipients** (e.g., a new host needs access):

1. Add the new host's public key to `.sops.yaml` under the relevant `creation_rule`
2. Run `sops updatekeys secrets/myshared.yaml` — this re-encrypts the data key for the new recipient and appends it to the `sops:` block
3. Commit the updated file — now the new host can decrypt it too

The existing encrypted values are untouched; only the metadata block gains a new entry.

## Common Operations

```bash
# Edit a secrets file (opens decrypted in $EDITOR, re-encrypts on save)
sops secrets/thinkpad.yaml

# Or without sops in PATH
nix shell nixpkgs#sops -c sops secrets/thinkpad.yaml

# Add a new host's key to an existing file's recipients
sops updatekeys secrets/common.yaml

# Generate a new age key
age-keygen -o /var/lib/sops/age/keys.txt
# output: Public key: age1...  ← add this to .sops.yaml
```

## Adding a New Host (Summary)

1. `age-keygen -o /var/lib/sops/age/keys.txt` on the new host
2. Copy to `~/.config/sops/age/keys.txt` (same file, different permissions/owner)
3. Add public key to `.sops.yaml` with a new YAML anchor
4. `sops secrets/newhost.yaml` — add `ssh_host_ed25519_key`
5. Add new host's key to any `common.yaml`-style creation rules, then `sops updatekeys secrets/common.yaml`
6. `just install` — ssh.nix detects the new file via `builtins.pathExists` and activates

## Key Files Reference

| File | Purpose |
|------|---------|
| `.sops.yaml` | Age recipients + per-file creation rules |
| `secrets/*.yaml` | Encrypted secret values |
| `modules/aspects/secrets.nix` | sops-nix module import + key file paths |
| `modules/aspects/ssh.nix` | SSH host/user key decryption (conditional) |
| `modules/aspects/nix-config.nix` | GitHub token → nix-daemon EnvironmentFile |
| `modules/aspects/rclone.nix` | rclone.conf decryption |
| `/var/lib/sops/age/keys.txt` | Age private key (system, NOT in repo) |
| `~/.config/sops/age/keys.txt` | Age private key (user copy, NOT in repo) |

The private age key is the **only** thing not in the repo. Back it up securely. Losing it means re-encrypting every secrets file with a new key.
