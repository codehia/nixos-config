# Dendritic Pattern — Design Reference

> Source: Doc-Steve/dendritic-design-with-flake-parts, mightyiam/dendritic, den.oeiuwq.com
> Config context: `/home/deus/workspace/personal/nixos-config/`

---

## What is the Dendritic Pattern?

A NixOS configuration design pattern with one core rule:

> "Every Nix file except for entry points (`default.nix`, `flake.nix`) is a module of
> the top-level configuration."

Each module must:
1. Implement a **single feature** (one concern)
2. Apply across **all configurations** where that feature is relevant
3. Be positioned at a path that **names** that feature

---

## Traditional vs Dendritic

### Traditional (host-centric):
```
hosts/
  laptop/
    configuration.nix    # ALL laptop config: services, packages, users
    hardware.nix
  server/
    configuration.nix    # ALL server config
```
- Adding a feature = editing every host file
- Code duplication when hosts share features
- Errors are spread across many files

### Dendritic (feature-centric):
```
modules/
  aspects/
    fish.nix              # Fish shell — applies everywhere it's included
    catppuccin.nix        # Theme — applies everywhere
    hyprland/             # Compositor group
    nvim/                 # Editor group
  hosts/
    personal/default.nix  # Includes relevant feature aspects
    thinkpad/default.nix
  users/
    deus.nix              # User aspect (includes user-relevant features)
    soumya.nix
```
- Adding a feature = create one file, include it where needed
- Zero duplication — one definition serves all hosts
- Errors are in one location per feature

---

## Seven Aspect Patterns

### 1. Simple Aspect
One concern, static config, no parametrization needed.

```nix
den.aspects.git = {
  nixos.programs.git.enable = true;
  homeManager.programs.git = {
    enable = true;
    delta.enable = true;
  };
};
```

### 2. Multi-Context Aspect
Feature needs both NixOS system config AND HM user config. Den routes them automatically.

```nix
den.aspects.pipewire = {
  nixos.services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  homeManager.services.easyeffects.enable = true;
};
```

### 3. Collector Aspect
Multiple files contribute to the same named aspect. Den merges them automatically.

```nix
# hyprland/hyprland.nix
den.aspects.hyprland = {
  nixos.programs.hyprland.enable = true;
  homeManager.wayland.windowManager.hyprland.enable = true;
};

# hyprland/binds.nix (separate file, same aspect name — auto-merged)
den.aspects.hyprland = {
  homeManager.wayland.windowManager.hyprland.settings.bind = [ ... ];
};

# hyprland/hyprpaper.nix
den.aspects.hyprland = {
  homeManager.services.hyprpaper = { ... };
};
```

Used by: `hyprland/`, `swayfx/`, `waybar/`, `nvim/`, `shell-tools/`.

### 4. Inheritance Aspect (Composition via includes)
Host/user aspects compose feature aspects.

```nix
den.aspects.personal = {
  includes = [
    den.aspects.nix-config
    den.aspects.networking
    den.aspects.boot
    den.aspects.pipewire
    den.aspects.hyprland
    den.aspects.greetd
  ];
};
```

### 5. Parametric Aspect (perHost / perUser)
Config varies by host or user properties. **Always use named let-bindings** — never inline
anonymous functions.

```nix
let
  lact-config = { host, ... }:
    lib.optionalAttrs (host ? gpuKey) {
      nixos.services.lact.settings.devices.${host.gpuKey} = { ... };
    };
in
den.aspects.lact = {
  nixos.services.lact.enable = true;
  includes = [ (den.lib.perHost lact-config) ];
};
```

### 6. Conditional Aspect
Config differs per host/user via `lib.optionalAttrs`.

```nix
let
  sshKeys = { user, ... }:
    let sopsFile = "${secrets}/${user.userName}.yaml";
    in lib.optionalAttrs (builtins.pathExists sopsFile) {
      homeManager.sops.secrets."${user.userName}_ssh_key" = { sopsFile = ...; };
    };
in
den.aspects.ssh = {
  nixos.services.openssh.enable = true;
  includes = [ (den.lib.perUser sshKeys) ];
};
```

### 7. Schema / Constants Aspect
Declares typed metadata options readable by all aspects.

```nix
# modules/schema.nix
den.schema.host = { host, lib, ... }: {
  options.wm = lib.mkOption { type = lib.types.str; default = "swayfx"; };
  options.nvimLanguages = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
};
```

---

## How Config Flows — Our Setup

```
Host: thinkpad
  den.aspects.thinkpad.includes = [
    den.aspects.nix-config      ← system config
    den.aspects.pipewire        ← audio
    den.aspects.greetd          ← login manager
    den.aspects.fonts           ← fonts
    ...
  ]

User: deus (on thinkpad)
  den.aspects.deus.includes = [
    den.provides.primary-user
    den.aspects.fish            ← shell
    den.aspects.catppuccin      ← theme
    den.aspects.nvim            ← editor
    (perUser wmSelector)        ← picks host.wm aspect (swayfx on thinkpad)
    (perUser extraAspectsSelector) ← picks host.extraAspects
    ...
  ]

User: soumya (on thinkpad)
  den.aspects.soumya.includes = [
    den.provides.primary-user
    den.aspects.fish
    den.aspects.hyprland        ← hardcoded, not from host.wm
    den.aspects.nvim
    ...
  ]
```

---

## Key Design Rules

| Rule | Rationale |
|------|-----------|
| No `mkIf` for host/user conditions inside aspects | Context IS the condition |
| No anonymous functions in `includes` | Hard to debug, no name in traces |
| No factory functions | Use freeform host/user attrs + perHost/perUser |
| Aspects focus on ONE concern | Easy to reason about, compose, remove |
| `_`-prefix excludes file from import-tree | For hardware configs, private data |
| `git add` new files before building | import-tree uses git for discovery |

---

## Supporting Libraries

| Library | Role |
|---------|------|
| `den` | Context pipeline, batteries, aspect composition |
| `flake-parts` | Underlying flake module system |
| `flake-file` | Inline `flake-file.inputs` declarations per module |
| `import-tree` | Auto-discovers all `.nix` files in `modules/` via git |

### flake-file example
```nix
# In any module file — declares its own flake input inline
flake-file.inputs.hyprland = {
  url = "github:hyprwm/hyprland";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```
Run `just write-flake` to regenerate `flake.nix` from all declarations.

---

## References

- [Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
- [mightyiam/dendritic](https://github.com/mightyiam/dendritic)
- `.claude/research/dendritic-design.md` — full pattern reference (local)
- `.claude/research/dendritic-design-charts.md` — visual diagrams (local)
