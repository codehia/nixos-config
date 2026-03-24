# Adding a Sops-Managed SSH Key for a New User

`ssh.nix` sets up a user's private SSH key from `secrets/<username>.yaml` if that file exists.
This note covers the full procedure to create it.

## Prerequisites

- `sops` and `age` available (`nix-shell -p sops age` if not)
- The host age key at `~/.config/sops/age/keys.txt` (so sops can encrypt)
- The host's age **public** key (shown by `age-keygen -y ~/.config/sops/age/keys.txt`)

## Step 1 — Add a creation rule to `.sops.yaml`

Add the host's age key as a recipient for the new user's secrets file.
For a user that only lives on one host (e.g. `soumya` on `workstation`):

```yaml
creation_rules:
  - path_regex: secrets/soumya\.yaml$
    key_groups:
      - age:
          - *workstation   # use whichever host anchor applies
```

If the user lives on multiple hosts, list all relevant host anchors.

## Step 2 — Generate an SSH key for the user

```bash
ssh-keygen -t ed25519 -f /tmp/new_user_ssh -N "" -C "soumya@workstation"
# /tmp/new_user_ssh     — private key
# /tmp/new_user_ssh.pub — public key (save this somewhere)
```

## Step 3 — Create the sops secrets file

```bash
# Read the private key into a variable so you can paste it into the editor
cat /tmp/new_user_ssh

sops secrets/soumya.yaml
```

In the editor sops opens, add:

```yaml
ssh_user_ed25519_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste private key content here>
    -----END OPENSSH PRIVATE KEY-----
```

The indentation under the `|` block scalar must be consistent (4 spaces shown above).

## Step 4 — Clean up the plaintext key

```bash
rm /tmp/new_user_ssh /tmp/new_user_ssh.pub
```

Keep the public key in a safe place if you need it for `authorized_keys` on remote servers.

## Step 5 — Rebuild

```bash
git add secrets/soumya.yaml
just install
```

`ssh.nix` will detect `secrets/soumya.yaml`, set `managed = true`, and place the private key
at `~/.ssh/id_ed25519` (mode 0600) via home-manager sops-nix on next activation.

## How `ssh.nix` picks this up

```nix
# ssh.nix — userKey
{ user, ... }:
let
  sopsFile = "${secrets}/${user.userName}.yaml";   # e.g. secrets/soumya.yaml
  managed  = builtins.pathExists sopsFile;          # true once file exists
in {
  homeManager = { config, lib, ... }: lib.mkIf managed {
    sops.secrets.ssh_user_ed25519_key = {
      inherit sopsFile;
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };
  };
}
```

## Adding a new host to an existing secrets file

If the user moves to a new host, re-encrypt the file with the new host key added:

```bash
# 1. Add the new host age key anchor to .sops.yaml and add it to the user's creation rule
# 2. Re-encrypt:
sops updatekeys secrets/soumya.yaml
```
