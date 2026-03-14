# Den Library & Framework — Research Notes

> Researched: 2026-03-14
> Sources: [den.oeiuwq.com](https://den.oeiuwq.com), [deepwiki.com/vic/den](https://deepwiki.com/vic/den), [github.com/vic/den](https://github.com/vic/den)

---

## What is Den?

Den is a **context-aware, dendritic Nix configuration system** that operates as both a library and a framework. The name reflects its branching architecture where "configurations branch and compose through aspect chains."

- **As a Library** (`den.lib`): Domain-agnostic utilities for context-aware parametric functions. Not tied to NixOS/Darwin — can be used for any Nix configuration domain (Terranix, NixVim, etc.).
- **As a Framework** (`den.hosts`, `den.homes`, `den.aspects`): Pre-configured schemas specifically for NixOS, nix-Darwin, and Home Manager with an integrated pipeline and batteries.

The framework is entirely optional — you can use `den.lib` directly without any of the `den.hosts`/`den.aspects` machinery.

---

## Core Principles

### 1. Feature-First, Not Host-First
Den inverts traditional config by prioritizing **aspects** (features) as the primary organizational unit. Each aspect declares its behavior per Nix class, and hosts simply select which aspects apply. Adding/removing a feature is typically a one-line change.

### 2. Context-Driven Dispatch
Functions declare required context through their parameter signatures. The system introspects function arguments at evaluation time, automatically running functions only when their declared context exists. A function requiring `{host, user}` only executes when both are present. **The context shape IS the condition** — no `mkIf` needed.

### 3. Composition via Includes
Aspects interconnect through `includes` (direct dependencies) and `provides` (reusable patterns), creating a DAG structure.

### 4. Separation of Concerns
Three clean layers: **Schema** (what exists) → **Aspects** (behavior) → **Context** (data flow orchestration).

---

## Three-Layer Architecture

```
┌─────────────────────────────────────────────┐
│  Integration Layer                          │
│  (Home Manager, Hjem, nix-maid forwarding)  │
├─────────────────────────────────────────────┤
│  Den Framework API (modules/)               │
│  den.hosts, den.homes, den.aspects,         │
│  den.ctx, den.provides, den.default         │
├─────────────────────────────────────────────┤
│  Den Core Library (nix/lib.nix)             │
│  parametric, canTake, take, ctxApply,       │
│  statics, owned, build helpers              │
├─────────────────────────────────────────────┤
│  Foundation: flake-aspects + nixpkgs        │
└─────────────────────────────────────────────┘
```

---

## Key API Surface

### Schema: `den.hosts` and `den.homes`

```nix
# Host declaration — OS-level system config
den.hosts.<system>.<name> = {
  users.<username> = {};           # Users on this host
  home-manager.enable = true;      # Enable HM integration
  # Options: name, hostName, system, class, aspect, instantiate, intoAttr
};

# Standalone home — independent of system control
den.homes.<system>.<name> = {};
```

**Outputs generated:**
- `nixosConfigurations.<name>` / `darwinConfigurations.<name>`
- `homeConfigurations."<user>@<host>"` (host-associated)
- `homeConfigurations.<name>` (standalone)

### Aspects: `den.aspects`

```nix
den.aspects.<name> = {
  nixos = { ... }: { /* NixOS module */ };
  darwin = { ... }: { /* nix-darwin module */ };
  homeManager = { ... }: { /* Home Manager module */ };
  user = { ... }: { /* per-user config */ };
  includes = [ /* other aspects */ ];
  provides = { /* namespaced sub-aspects */ };
};
```

An aspect is a reusable configuration unit containing per-class configs. Multiple files can contribute to the same aspect (collector pattern).

### Defaults: `den.default`

```nix
den.default = {
  nixos.system.stateVersion = "25.11";
  homeManager.home.stateVersion = "25.11";
};
```

Applied globally across all hosts/users.

### Built-in Batteries: `den.provides` / `den._`

| Battery | Purpose |
|---------|---------|
| `den._.primary-user` / `den.provides.primary-user` | Marks user as primary |
| `den._.user-shell "fish"` / `den.provides.user-shell` | Sets login shell |
| `den._.hostname` / `den.provides.hostname` | Sets system hostname from host name |
| `den._.define-user` / `den.provides.define-user` | Creates user accounts |
| `den.provides.forward` | Custom class forwarding |
| `den.provides.unfree` | Unfree packages allowlist |

### Context Types: `den.ctx`

| Type | Data | Purpose |
|------|------|---------|
| `den.ctx.host` | `{ host }` | Per-system host config |
| `den.ctx.user` | `{ host, user }` | User-specific settings |
| `den.ctx.home` | `{ home }` | Standalone home configs |
| `den.ctx.hm-host` | `{ host }` | Home Manager OS integration |
| `den.ctx.hm-user` | `{ host, user }` | Home Manager user config |
| `den.ctx.wsl-host` | `{ host }` | WSL-enabled host support |

Custom context types can be defined for specialized configs (GPU, etc.).

---

## Context Pipeline (How Configs Flow)

```
den.hosts declaration
  │
  ├─► 1. Host Context {host}
  │     - fixedTo {host}: owned configs + statics + parametric matches
  │     - atLeast {host, user}: parametric matches only
  │
  ├─► 2. User Context {host, user} (for each user)
  │     - fixedTo {host, user}
  │
  ├─► 3. Derived Contexts (from batteries)
  │     ├─► into.hm-host (if HM enabled with users)
  │     ├─► into.hm-user (per HM user)
  │     ├─► into.wsl-host (if WSL enabled)
  │     ├─► into.hjem-host (if Hjem enabled)
  │     └─► into.maid-host (if nix-maid enabled)
  │
  ├─► 4. Deduplication
  │     First occurrence: fixedTo (owned + statics + parametric)
  │     Subsequent: atLeast (parametric only)
  │
  └─► 5. Output Generation
        → nixosConfigurations / darwinConfigurations / homeConfigurations
```

Standalone `den.homes` entries bypass host processing entirely — apply `fixedTo {home}` directly.

---

## Parametric Functions

Den's `__functor` pattern enables context-aware dispatch:

```nix
# A parametric aspect that only activates for {host, user} contexts
den.aspects.example = {
  includes = [
    ({ host, user, ... }: {
      homeManager.home.sessionVariables.HOST = host.name;
    })
  ];
};
```

Key library functions:
- `den.lib.parametric` — Wraps aspects with context-aware dispatch
- `den.lib.canTake` / `den.lib.take` — Conditionally apply based on parameter matching
- `den.lib.statics` / `den.lib.owned` — Extract configuration subsets

---

## Custom Classes via `den.provides.forward`

Create domain-specific configuration containers that forward to target classes:

```nix
den.provides.forward {
  each = [ /* items to forward */ ];
  fromClass = "myClass";       # Custom class name
  intoClass = "nixos";         # Target class
  intoPath = "some.attr.path"; # Where to place in target
  fromAspect = /* resolver */;
  guard = /* conditional */;    # Optional: only forward if option exists
}
```

Built-in forwards:
- `user` → `users.users.<name>` (on nixos/darwin)
- `homeManager` → `home-manager.users.<name>`

---

## Namespaces

Organize aspect libraries under `den.ful.<name>`:

```nix
# Create a local namespace
imports = [ (inputs.den.namespace "my" false) ];

# Create an exported namespace (shared via flake outputs)
imports = [ (inputs.den.namespace "eg" true) ];

# Populate
eg.vim = {
  homeManager.programs.vim.enable = true;
};

# Use
den.aspects.laptop.includes = [ eg.desktop eg.vim ];

# Import upstream namespace
imports = [ (inputs.den.namespace "shared" [ inputs.team-config ]) ];
```

Angle bracket syntax shorthand: `<eg/desktop>` instead of `eg.desktop`.

---

## Templates

| Template | Description |
|----------|-------------|
| `default` | Full-featured: flakes + flake-parts + home-manager |
| `minimal` | Basic flake setup |
| `example` | Cross-platform NixOS/Darwin reference |
| `noflake` | Uses npins + nix-maid instead of flakes |
| `ci` | CI/CD testing patterns |
| `microvm` | MicroVM support with custom pipelines |

Initialize: `nix flake init -t github:vic/den#<template>`

---

## Dependencies

| Dependency | Purpose |
|-----------|---------|
| `flake-aspects` | Aspect composition and resolution primitives |
| `import-tree` | Recursive module auto-discovery |
| `flake-file` | Inline flake input declarations |
| `nixpkgs` | Package collection |
| `home-manager` | User environment management (optional) |
| `flake-parts` | Flake composition (optional, recommended) |
| `with-inputs` | Flake compatibility for non-flake setups |

---

## From Zero to Den (Quick Start)

### Non-flake approach:
```bash
mkdir ./modules
npins init
npins add github vic import-tree -b main
npins add github vic flake-aspects -b main
npins add github vic den -b main
npins add github vic with-inputs -b main
```

### Entry point (`default.nix`):
```nix
let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources {};
  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs.inputs = inputs;
    }).config.flake;
in with-inputs outputs
```

### Flake approach (what our config uses):
```nix
# dendritic.nix
{ inputs, ... }: {
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.den.flakeModules.dendritic
  ];
  flake-file.inputs = {
    den = { url = "github:vic/den"; };
    flake-file = { url = "github:vic/flake-file"; };
    flake-parts = { url = "github:hercules-ci/flake-parts"; };
    import-tree = { url = "github:vic/import-tree"; };
    flake-aspects = { url = "github:vic/flake-aspects"; };
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.11"; };
  };
  systems = ["x86_64-linux"];
}
```

---

## Summary for Implementation

### What You Need to Know

1. **Aspects are the core unit** — Each feature (fish, catppuccin, hyprland) is a `den.aspects.<name>` with per-class configs (`nixos`, `homeManager`, `darwin`).

2. **Hosts declare what exists** — `den.hosts.<system>.<name>.users.<user> = {}` is purely declarative. Aspects with matching names auto-attach.

3. **`includes` for composition** — Use `den._.primary-user`, `den._.user-shell "fish"`, `den._.hostname`, etc. for common patterns. Include other aspects for dependencies.

4. **`den.default` for globals** — Set `stateVersion` and other cross-host defaults here.

5. **Context drives activation** — Functions in `includes` receive `{host}`, `{host, user}`, or `{home}` and only run when context matches. No `mkIf` needed for context-dependent behavior.

6. **Collector pattern** — Multiple files can contribute to the same `den.aspects.<name>`. They merge automatically.

7. **Custom classes** via `den.provides.forward` — Route config from one class to another (e.g., user class → `users.users.<name>`).

8. **Namespaces** for sharing — `den.ful.<name>` organizes aspect libraries; can be exported/imported across flakes.

9. **`flake-file.inputs`** — Each module declares its own flake inputs inline. Run `just write-flake` to regenerate `flake.nix`.

10. **`import-tree`** auto-discovers all `.nix` files in `modules/` — files prefixed with `_` are excluded.
