# Den — Framework Reference

> Source: vic/den (v0.13.0), den.oeiuwq.com
> Config context: `/home/deus/workspace/personal/nixos-config/`

---

## What is Den?

Den is a **context-aware, aspect-oriented Nix configuration framework** built on top of
flake-parts. It implements the dendritic pattern — configuration flows feature-first,
not host-first.

It operates as two things simultaneously:
- **A library** (`den.lib`): parametric dispatch, context-aware functions, aspect composition
- **A framework** (`den.hosts`, `den.aspects`, etc.): pre-wired NixOS + HM + Darwin pipeline

---

## Three-Layer Architecture

```
+==============================================================+
|  INTEGRATION LAYER                                           |
|  Home Manager · Hjem · nix-maid · WSL                       |
|  (opt-in: user.classes = ["homeManager"])                    |
+==============================================================+
|  DEN FRAMEWORK API                                           |
|  den.hosts     den.homes     den.schema                      |
|  den.aspects   den.default   den.provides   den.ctx          |
+==============================================================+
|  DEN CORE LIBRARY (nix/lib/)                                 |
|  parametric · canTake · take · ctxApply                      |
|  perHost · perUser · perHome · aspects.resolve               |
+==============================================================+
|  FOUNDATION: flake-aspects v0.7.0 + nixpkgs                 |
+==============================================================+
```

---

## Core Concepts

### Context IS the Condition

Never use `mkIf` for host/user conditions. A function `{ host, ... }:` is automatically
skipped in contexts that don't have `host`. The argument signature IS the conditional.

```nix
# BAD
nixos = { host, lib, ... }: lib.mkIf host.isLaptop { ... };

# GOOD
includes = [ (den.lib.perHost ({ host, ... }: lib.optionalAttrs host.isLaptop {
  nixos.services.tlp.enable = true;
})) ];
```

### Aspects Are Functors

Every aspect has a `__functor` added by den that inspects context parameters via
`builtins.functionArgs` and decides which includes to apply.

### Attrset Form vs Function Form

```nix
# PREFER: static attrset form
den.aspects.foo = {
  nixos.services.foo.enable = true;
  homeManager.programs.foo.enable = true;
};

# Only when pkgs/lib/inputs access needed:
den.aspects.foo = {
  nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.foo ]; };
};
```

---

## API Reference

### `den.hosts`

Declares NixOS hosts. Each key becomes a `nixosConfigurations` output.

```nix
den.hosts.x86_64-linux.personal = {
  home-manager.enable = true;    # activates HM integration
  wm = "swayfx";                 # freeform attr (readable as host.wm)
  greetdUser = "deus";           # freeform attr
  nvimLanguages = [ "lua" "nix" ];
  users.deus = {};               # declares user context
  users.soumya = { nvimLanguages = [ "python" ]; };
};
```

### `den.aspects`

Declares a named aspect. Multiple files can define the same aspect name — they are merged
(collector pattern).

```nix
den.aspects.myfeature = {
  nixos = { ... };               # NixOS system config
  homeManager = { ... };         # HM user config
  darwin = { ... };              # macOS config
  includes = [ ... ];            # composed sub-aspects
};
```

### `den.schema`

Typed option declarations applied to all entities of their kind. NOT aspects — metadata only.

| Option | Applied to |
|--------|-----------|
| `den.schema.conf` | ALL hosts, users, AND homes |
| `den.schema.host` | All hosts |
| `den.schema.user` | All users |
| `den.schema.home` | All homes |

```nix
# modules/schema.nix
den.schema.user.config.classes = lib.mkDefault ["homeManager"];
# ^ This is what activates HM. Without it, HM is silently dropped.
```

### `den.default`

An aspect applied globally to all hosts/users. Use for universal defaults.

```nix
# modules/defaults.nix
den.default = {
  nixos.system.stateVersion = "24.05";
  includes = [ den.provides.mutual-provider ];
};
```

### `den.lib.perHost` / `den.lib.perUser` / `den.lib.perHome`

Wrappers that restrict an aspect function to a specific context type.

```nix
includes = [
  (den.lib.perHost ({ host, ... }: {
    nixos.networking.hostName = host.hostName;
  }))
  (den.lib.perUser ({ user, host, ... }: {
    homeManager.home.username = user.userName;
  }))
];
```

### `den.provides.*` (Batteries)

Pre-built common patterns:

| Battery | Purpose |
|---------|---------|
| `den.provides.primary-user` | Marks user as primary (uid 1000, wheel group) |
| `den.provides.user-shell "fish"` | Sets default shell for user |
| `den.provides.mutual-provider` | Routes HM config from aspects to users |
| `den.provides.forward` | Custom Nix class forwarding |

> **Deprecated:** `den.provides.home-manager` — throws error. Use `home-manager.enable = true` on the host instead.

---

## Context Pipeline — Full Data Flow

```
den.hosts.x86_64-linux.personal.users.deus = {}
den.aspects.personal = { ... }
den.aspects.deus = { ... }
         |
         v
  [den.ctx.host { host = personal }]
    - applies den.aspects.personal
    - applies den.default
    - fans out → den.ctx.user per declared user
         |
         +---> [den.ctx.user { host = personal, user = deus }]
         |       - applies den.aspects.deus
         |       - applies den.default
         |
         +---> [den.ctx.hm-host { host = personal }]
         |       - imports home-manager NixOS module
         |       - fans out → den.ctx.hm-user per HM-class user
         |
         +---> [den.ctx.hm-user { host = personal, user = deus }]
                 - forwards homeManager.* → home-manager.users.deus
         |
         v
  Output: flake.nixosConfigurations.personal
```

---

## HM Integration — How It Activates

Three things must all be true for HM to activate:

1. `home-manager.enable = true` on the host declaration
2. `den.schema.user.config.classes = lib.mkDefault ["homeManager"]` in schema.nix
3. User declared in `host.users.*`

Without #2, `homeManager.*` configs are silently dropped. This is the most common "HM isn't working" cause.

---

## Freeform Host Attrs (our config)

Declared in `den.hosts.*` as plain attrset keys, readable as `host.*` in aspects:

| Attr | Used by |
|------|---------|
| `wm` | `deus.nix` wmSelector → picks aspect by name |
| `extraAspects` | `deus.nix` extraAspectsSelector |
| `nvimLanguages` | `nvim.nix` perUser |
| `greetdUser` | `greetd.nix` |
| `greetdSessionBin` | `greetd.nix` |
| `gpuKey` | `lact.nix` perHost |
| `nhCleanEnabled` | `nix-config.nix` perHost |
| `isLaptop` | laptop-specific config |

Built-in (from den): `host.hostName` (from declaration key), `user.userName` (from declaration key).

---

## Import-Tree Integration

`import-tree` auto-discovers all `.nix` files under `modules/` via git.
- Files/directories prefixed with `_` are **excluded**
- **New files must be `git add`ed** before they are visible to the build
- No manual import lists needed — just create the file and stage it

---

## Key Files in Our Config

| File | Purpose |
|------|---------|
| `modules/den.nix` | Bootstraps den + flake-file + import-tree |
| `modules/defaults.nix` | `den.default` + stateVersion + mutual-provider |
| `modules/schema.nix` | `den.schema.conf` (unstable overlay), `den.schema.user` (classes default) |
| `modules/hosts/*/default.nix` | Host aspects + declarations |
| `modules/users/deus.nix` | deus user aspect |
| `modules/users/soumya.nix` | soumya user aspect |

---

## Style Rules (DO / DON'T)

| DO | DON'T |
|----|-------|
| Attrset form for static config | Anonymous functions in `includes` |
| Named let-bindings for parametric includes | Factory functions |
| `den.lib.perHost/perUser` for parametric dispatch | `mkIf` for host/user conditions inside aspects |
| `lib.optionalAttrs` for conditional inclusion | `den.provides.home-manager` (deprecated) |
| `git add` new files before building | `nix eval`/`nix repl` (RAM spike) |

---

## References

- [vic/den](https://github.com/vic/den)
- [den.oeiuwq.com](https://den.oeiuwq.com)
- `.claude/research/den.md` — full API reference (local)
- `.claude/research/den-charts.md` — visual diagrams (local)
