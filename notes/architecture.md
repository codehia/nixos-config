# How Everything Fits Together

This document explains the complete picture — from `.nix` files to a running system.
Useful for both humans and AI agents navigating this codebase.

---

## The Nix store

The `/nix/store` is an immutable, content-addressed storage directory. Every package,
config file, and script lives here as `/nix/store/<hash>-<name>/`. Nothing outside the
store is ever modified by a build (except symlinks in `/run`, `/etc`, `~`).

```
/nix/store/
  abc123-hyprland-0.54.0/    ← a build output
  def456-hyprland-0.54.0.drv ← the build recipe (derivation)
  ghi789-nixos-system-*/     ← the entire NixOS system closure
    activate                  ← script that switches to this generation
    sw/bin/                   ← all binaries
```

**Why this matters for debugging:**
- Packages don't conflict — each lives in its own store path
- Old generations are just old symlinks — `just clean` removes unreferenced paths
- `nix-store -q --references /path/to/thing` shows what a path depends on
- Never try to read source from the store — clone repos to `/tmp` instead

---

## From `.nix` files to a running system

```mermaid
flowchart TD
    subgraph source["Source: nixos-config/"]
        NF["flake.nix\n(auto-generated)"]
        LOCK["flake.lock\n(pinned hashes)"]
        MODS["modules/**/*.nix\n(auto-discovered via git)"]
    end

    subgraph eval["Phase 1: Evaluation"]
        IT["import-tree scans git\ncollects all .nix files"]
        FP["flake-parts merges\nflake modules"]
        DEN["den resolves\nhost/user context pipeline"]
        TREE["Final attrset:\nnixosConfigurations.workstation"]
    end

    subgraph inst["Phase 2: Instantiation"]
        DRV[".drv files written\nto /nix/store"]
    end

    subgraph build["Phase 3: Build"]
        SUB{"Cache hit?\n(hyprland.cachix.org)"}
        DL["Download pre-built\nbinary from cache"]
        COMP["Compile from source\n(slow path)"]
        OUT["/nix/store/<hash>-*/\nbuild outputs"]
    end

    subgraph activate["Phase 4: Activation"]
        SWITCH["nixos-rebuild switch\n(or nh os switch)"]
        LINKS["/run/current-system → new generation\n/etc/* updated\nsystemd units reloaded"]
    end

    NF --> IT
    LOCK --> IT
    MODS --> IT
    IT --> FP
    FP --> DEN
    DEN --> TREE
    TREE --> DRV
    DRV --> SUB
    SUB -->|yes| DL
    SUB -->|no| COMP
    DL --> OUT
    COMP --> OUT
    OUT --> SWITCH
    SWITCH --> LINKS

    style eval fill:#1e1e2e,color:#cdd6f4
    style inst fill:#1e1e2e,color:#cdd6f4
    style build fill:#1e1e2e,color:#cdd6f4
    style activate fill:#1e1e2e,color:#cdd6f4
    style SUB fill:#313244,color:#f9e2af
    style DL fill:#313244,color:#a6e3a1
    style COMP fill:#313244,color:#f38ba8
```

---

## The den context pipeline (zoomed in)

```mermaid
flowchart TD
    HOST_DECL["den.hosts.x86_64-linux.workstation = {\n  home-manager.enable = true;\n  wm = 'hyprland';\n  users.deus = {};\n  users.soumya = {};\n}"]

    HOST_DECL --> HOST_CTX

    subgraph HOST_CTX["Host context { host = workstation }"]
        HA["den.aspects.workstation applied\n(nixos.* → NixOS system config)"]
        DA["den.default applied\n(stateVersion, mutual-provider)"]
    end

    HOST_CTX --> USER_CTX_D
    HOST_CTX --> USER_CTX_S

    subgraph USER_CTX_D["User context { host, user = deus }"]
        UA_D["den.aspects.deus applied\n(wmSelector picks hyprland\nextraAspectsSelector runs)"]
        HM_D["homeManager.* forwarded to\nhome-manager.users.deus"]
    end

    subgraph USER_CTX_S["User context { host, user = soumya }"]
        UA_S["den.aspects.soumya applied\n(hardcoded hyprland aspect)"]
        HM_S["homeManager.* forwarded to\nhome-manager.users.soumya"]
    end

    HOST_CTX --> OUTPUT
    USER_CTX_D --> OUTPUT
    USER_CTX_S --> OUTPUT

    OUTPUT["nixosConfigurations.workstation\n(full merged NixOS config)"]

    style HOST_CTX fill:#313244,color:#cdd6f4
    style USER_CTX_D fill:#1e1e2e,color:#cba6f7
    style USER_CTX_S fill:#1e1e2e,color:#89b4fa
    style OUTPUT fill:#45475a,color:#a6e3a1
```

---

## How config from aspects reaches NixOS

```mermaid
flowchart LR
    subgraph aspect["den.aspects.fish"]
        N["nixos.programs.fish.enable = true"]
        HM["homeManager.programs.fish.enable = true"]
    end

    subgraph sys["NixOS system config"]
        SYS["programs.fish.enable = true\n(system-level, all users)"]
    end

    subgraph user["home-manager.users.deus"]
        USR["programs.fish.enable = true\n(user dotfiles + config)"]
    end

    N -->|"merged into"| SYS
    HM -->|"forwarded by den\nvia mutual-provider"| USR

    style aspect fill:#313244,color:#cdd6f4
    style sys fill:#1e1e2e,color:#89b4fa
    style user fill:#1e1e2e,color:#cba6f7
```

---

## File lookup guide (for humans and AI agents)

| You want to... | Look in... |
|---------------|-----------|
| Change a host's packages / services | `modules/hosts/<hostname>/default.nix` |
| Change a user's dotfiles / programs | `modules/aspects/<feature>.nix` (homeManager block) |
| Add a feature to all users | `modules/users/deus.nix` or `soumya.nix` includes |
| Add a feature to one host only | `extraAspects` in the host declaration |
| Change system-level config | `modules/aspects/<feature>.nix` (nixos block) |
| Add a new flake input | inline `flake-file.inputs` in the relevant aspect file |
| Change Neovim config | `modules/aspects/nvim/` |
| Change Hyprland config | `modules/aspects/hyprland/` |
| Change theming | `modules/aspects/appearance.nix` |
| Change secrets | `sops secrets/<name>.yaml` |
| See what `host.wm` etc. means | `modules/schema.nix` |
| Understand what runs on each host | `modules/hosts/<hostname>/default.nix` includes list |

---

## Why AI agents sometimes look in the wrong places

**`/nix/store`** — agents sometimes try to read package source from here. Don't. The
store has compiled outputs, not source. Clone the repo to `/tmp` instead.

**`nix eval`** — causes a RAM spike on large flakes. Use `just dry` or `just repl`.

**`flake.nix`** — agents sometimes try to edit it. It's auto-generated. Edit the
relevant `modules/` file instead, then run `just write-flake`.

**`imports = [...]`** — agents from other NixOS configs expect explicit import lists.
This config uses `import-tree` — there are no import lists. New files just need
`git add`.

---

## Secrets (sops-nix)

Secrets are YAML files encrypted with age keys. Keys are safe to see in plaintext,
values are encrypted.

```
secrets/
  common.yaml        # shared across all hosts (github_token, etc.)
  deus.yaml          # deus's SSH key + password (all hosts)
  soumya.yaml        # soumya's SSH key + password
  rclone.yaml        # rclone config (personal + thinkpad only)
```

Each host decrypts secrets using its SSH host key — sops-nix derives an age key from
`/etc/ssh/ssh_host_ed25519_key` automatically. No manual age key file needed.

Edit secrets: `sops secrets/deus.yaml` (decrypts, opens editor, re-encrypts on save).

---

## Generation management

NixOS keeps every past system build as a "generation". Each generation is a complete
system closure in the store.

```bash
just history     # list generations
just clean       # remove old ones (GC)
```

If something breaks after `just install`, you can boot into the previous generation
from the bootloader menu (it's still in the store until cleaned).
