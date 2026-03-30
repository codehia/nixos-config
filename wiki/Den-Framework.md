# Den — Framework Reference

> Source: vic/den (v0.13.0), den.oeiuwq.com

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
  home-manager.enable = true;
  wm = "swayfx";
  greetdUser = "deus";
  nvimLanguages = [ "lua" "nix" ];
  users.deus = {};
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
         |
         v
  [den.ctx.host { host = personal }]
    - applies den.aspects.personal
    - applies den.default
    - fans out → den.ctx.user per declared user
         |
         +---> [den.ctx.user { host = personal, user = deus }]
         |       - applies den.aspects.deus
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

## Freeform Host Attrs

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

Built-in: `host.hostName` (from declaration key), `user.userName` (from declaration key).

---

## Style Rules

| DO | DON'T |
|----|-------|
| Attrset form for static config | Anonymous functions in `includes` |
| Named let-bindings for parametric includes | Factory functions |
| `den.lib.perHost/perUser` for parametric dispatch | `mkIf` for host/user conditions |
| `lib.optionalAttrs` for conditional inclusion | `den.provides.home-manager` (deprecated) |
| `git add` new files before building | `nix eval`/`nix repl` (RAM spike) |

---

## References

- [vic/den](https://github.com/vic/den)
- [den.oeiuwq.com](https://den.oeiuwq.com)
- See also: [[Dendritic-Pattern]]
