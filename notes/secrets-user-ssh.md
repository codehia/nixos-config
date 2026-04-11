# Adding a Sops-Managed SSH Key for a New User

`ssh.nix` sets up a user's private SSH key from `secrets/<username>.yaml` if that file exists.
This note covers the full procedure to create it.

## Prerequisites

- `sops` available (`nix shell nixpkgs#sops` if not)
- The host's age **public** key — derived from the SSH host key: `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age`

## Step 1 — Add a creation rule to `.sops.yaml`

Add the relevant host age keys as recipients for the new user's secrets file.
For a user that lives on workstation and thinkpad:

```yaml
creation_rules:
  - path_regex: secrets/soumya\.yaml$
    key_groups:
      - age:
          - *workstation
          - *thinkpad
```

## Step 2 — Generate an SSH key for the user

```bash
ssh-keygen -t ed25519 -f /tmp/new_user_ssh -N "" -C "soumya@workstation"
# /tmp/new_user_ssh     — private key
# /tmp/new_user_ssh.pub — public key (add this to authorized_keys in the user's .nix file)
```

## Step 3 — Create the sops secrets file

```bash
sops secrets/soumya.yaml
```

In the editor sops opens, add:

```yaml
ssh_user_ed25519_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste private key content here>
    -----END OPENSSH PRIVATE KEY-----
```

## Step 4 — Add the public key to the user's NixOS config

```nix
users.users.soumya.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... soumya@workstation"
];
```

## Step 5 — Clean up the plaintext key

```bash
rm /tmp/new_user_ssh /tmp/new_user_ssh.pub
```

## Step 6 — Rebuild

```bash
git add secrets/soumya.yaml
just install
```

`ssh.nix` will detect `secrets/soumya.yaml`, set `managed = true`, and place the private key
at `~/.ssh/id_ed25519` (mode 0600) via NixOS-level sops-nix on every boot.

## How `ssh.nix` picks this up

```nix
# ssh.nix — userKey
{ user, ... }:
let
  sopsFile = "${secrets}/${user.userName}.yaml";   # e.g. secrets/soumya.yaml
  managed  = builtins.pathExists sopsFile;          # true once file exists
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
}
```

Keys are placed at system level (not home-manager) so they're available on every boot, not just after login. Secret names are unique per user (`ssh-<username>`) to avoid collisions on multi-user hosts.

## Adding a new host to an existing secrets file

If the user moves to a new host, re-encrypt the file with the new host key added:

```bash
# 1. Get the new host's age key: cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# 2. Add the new anchor to .sops.yaml and add it to the user's creation rule
# 3. Re-encrypt:
sops updatekeys secrets/soumya.yaml
```
