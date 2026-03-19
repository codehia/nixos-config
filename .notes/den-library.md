# Den Library & Framework — Research Notes

> Updated: 2026-03-18
> Sources: [den.oeiuwq.com](https://den.oeiuwq.com), [AGENTS_EXAMPLE.md commit 91bf41d](https://github.com/vic/den/commit/91bf41d5a40c043a8a1492455125597f6b3dbba2), [github.com/vic/den](https://github.com/vic/den), [CI tests](https://github.com/vic/den/tree/main/templates/ci/modules/features/)

---

## What is Den?

Den is a **context-aware, dendritic Nix configuration system** operating as both a library and a framework.

- **As a Library** (`den.lib`): Domain-agnostic utilities for context-aware parametric functions. Works for any Nix domain.
- **As a Framework** (`den.hosts`, `den.homes`, `den.aspects`): Pre-configured schemas for NixOS, nix-Darwin, and Home Manager with integrated pipeline and batteries.

---

## Foundational Axioms

1. **Features first, hosts second.** Organize by concern, not machine.
2. **Context IS the condition.** Never write `mkIf` inside aspects. A function taking `{ host, user }` is skipped in `{ host }`-only contexts.
3. **No anonymous functions in includes.** Always name them as aspects or let-bindings. Improves error traces.
4. **Prefer attrset form for static owned configs.** `nixos.foo = val` over `nixos = _: { foo = val; }`.
5. **Aspects are short and focused on ONE concern.**

---

## Style (from AGENTS_EXAMPLE.md)

```nix
{ den, lib, inputs, ... }:
let
  inherit (den.lib) perHost;

  set-hostname = { host }: {
    nixos.networking.hostName = host.hostName;
  };
in {
  den.aspects.igloo.includes = [
    (perHost set-hostname)
  ];
}
```

Rules:
- Use let-bindings; keep the final attrset short
- **Never** inline anonymous functions in `includes` — name them in let or as `den.aspects.*`
- **ALWAYS prefer attrset form** for static class data: `nixos.foo = val` not `nixos = _: { foo = val; }`
- Use `nixos = { pkgs, ... }: {...}` only when you need pkgs/lib/config

---

## Three-Layer Architecture

```
┌──────────────────────────────────────────────────────┐
│  Integration Layer                                   │
│  (Home Manager, Hjem, nix-maid, WSL forwarding)      │
├──────────────────────────────────────────────────────┤
│  Den Framework API (modules/)                        │
│  den.hosts, den.homes, den.aspects,                  │
│  den.ctx, den.provides, den.default, den.schema      │
├──────────────────────────────────────────────────────┤
│  Den Core Library (nix/lib/ — split from lib.nix)    │
│  parametric, canTake, take, ctxApply, statics,       │
│  owned, perHost, perUser, perHome, aspects, funk      │
├──────────────────────────────────────────────────────┤
│  Foundation: flake-aspects + nixpkgs                 │
└──────────────────────────────────────────────────────┘
```

**Note:** As of commit `0def158d`, `nix/lib.nix` was split into `nix/lib/` directory with individual files.

---

## `den.schema` — Shared Metadata

Base modules merged into all entities of their kind. NOT aspects themselves — typed-option metadata that aspects can read.

```nix
{ lib, ... }: {
  den.schema.conf = { lib, ... }: {
    # Applies to ALL host/user/home
    options.copyright = lib.mkOption { default = "Copy-Left"; };
  };

  den.schema.host = { host, lib, ... }: {
    # Applies to all hosts (auto-imports conf)
    options.roles    = lib.mkOption { default = []; type = lib.types.listOf lib.types.str; };
    options.hardened = lib.mkEnableOption "hardened profile";
  };

  den.schema.user = { user, lib, ... }: {
    # Applies to all users (auto-imports conf)
    config.classes = lib.mkDefault [ "homeManager" ];
  };
}
```

| Option | Description |
|--------|-------------|
| `den.schema.conf` | Applied to host, user, and home |
| `den.schema.host` | Applied to all hosts (imports conf) |
| `den.schema.user` | Applied to all users (imports conf) |
| `den.schema.home` | Applied to all homes (imports conf) |

---

## `den.hosts`

```nix
den.hosts.x86_64-linux.laptop = {
  users.alice = {};
  users.bob.classes = [ "homeManager" "hjem" ];
  gpu = "nvidia";       # freeform — readable as host.gpu in aspects
  roles = [ "devops" ]; # custom metadata for role-based dispatch
  home-manager.enable = true;
};
```

**Host options:**

| Option | Default | Description |
|--------|---------|-------------|
| `name` | attr key | Configuration name |
| `hostName` | `name` | Network hostname |
| `system` | parent key | Platform |
| `class` | auto | `"nixos"` or `"darwin"` |
| `aspect` | `name` | Primary aspect name |
| `users` | `{}` | Users on this host |
| `instantiate` | auto | OS builder function |
| `*` | | Any freeform attribute |

**User options:**

| Option | Default | Description |
|--------|---------|-------------|
| `name` | attr key | User name |
| `userName` | `name` | System account name |
| `classes` | `["homeManager"]` | Home management classes |
| `aspect` | `name` | Primary aspect name |

> **CRITICAL:** The official docs say `classes` defaults to `["homeManager"]`. The source (`nix/lib/types.nix`) shows `["user"]`. Always set `den.schema.user.classes = lib.mkDefault ["homeManager"]` explicitly — required for `ctx.hm-host` to activate.

---

## `den.aspects` — Anatomy

```nix
den.aspects.bluetooth = {
  # Owned configs — ALWAYS prefer attrset form for static data
  nixos.hardware.bluetooth.enable      = true;
  nixos.hardware.bluetooth.powerOnBoot = true;
  darwin.services.blueutil.enable      = true;
  os.environment.systemPackages        = [ pkgs.bluez ]; # both nixos + darwin

  # Function form only when you need pkgs/lib/config
  homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.blueman ];
  };

  # Includes — ALWAYS named, never anonymous lambdas
  includes = [
    den.aspects.pipewire
    den.aspects.bluetooth._.applet   # sub-aspect via provides
  ];

  # Sub-aspects (accessible via den.aspects.bluetooth._.applet or .provides.applet)
  provides.applet = {
    homeManager.services.blueman-applet.enable = true;
  };
};
```

**Built-in classes:**

| Class | Maps to |
|-------|---------|
| `nixos` | NixOS modules |
| `darwin` | nix-darwin modules |
| `os` | Both `nixos` AND `darwin` (built-in forward, no path) |
| `homeManager` | `home-manager.users.<userName>` |
| `user` | `users.users.<userName>` (OS-level, no HM needed) |
| `hjem` | `hjem.users.<userName>` |
| `maid` | `users.users.<userName>.maid` |

---

## `den.default`

Applied globally to all hosts/users/homes. Owned configs deduplicated. Parametric functions in `includes` run at EVERY context stage — use `den.lib.take.exactly` or `perHost`/`perUser` to restrict.

```nix
{ den, ... }: {
  den.default = {
    nixos.system.stateVersion     = "25.11";
    homeManager.home.stateVersion = "25.11";
    darwin.system.stateVersion    = 5;
    includes = [
      den.provides.define-user   # creates users.users.<name> + home dirs
      den.provides.hostname      # sets networking.hostName
      den.provides.inputs'       # flake-parts inputs' in all modules
    ];
  };
}
```

---

## Batteries: `den.provides` / `den._`

| Battery | Purpose |
|---------|---------|
| `den._.define-user` | Creates `users.users.<name>` (`isNormalUser`, home dir) + `home.username`/`home.homeDirectory` |
| `den._.hostname` | Sets `networking.hostName` from `host.hostName` |
| `den._.primary-user` | NixOS: `wheel`+`networkmanager`+`isNormalUser`. Darwin: `system.primaryUser`. WSL: `defaultUser` |
| `(den._.user-shell "fish")` | OS shell + HM `programs.<shell>.enable` + `users.users.<name>.shell` |
| `(den._.unfree ["pkg"])` | `nixpkgs.config.allowUnfreePredicate` |
| `(den._.tty-autologin "user")` | `services.getty.autologinUser` on NixOS |
| `den._.bidirectional` | Host contributes config to user home environments |
| `den._.mutual-provider` | Explicit named host↔user cross-config via `provides.<name>` |
| `den._.forward {...}` | Create custom Nix classes |
| `(den._.import-tree ./dir)` | Auto-imports non-dendritic `.nix` dirs |
| `(den._.import-tree._.host ./dir)` | Per-host import-tree |
| `(den._.import-tree._.user ./dir)` | Per-user import-tree |
| `den._.inputs'` | flake-parts `inputs'` in all module args |
| `den._.self'` | flake-parts `self'` in all module args |
| `den._.home-manager` | **DEPRECATED — THROWS ERROR.** Use `home-manager.enable = true` on host |

---

## `den.lib` API

### Context Wrappers (preferred over anonymous lambdas)

| Function | Wraps with |
|----------|-----------|
| `den.lib.perHost aspect` | exactly `{host}` |
| `den.lib.perUser aspect` | exactly `{host, user}` |
| `den.lib.perHome aspect` | exactly `{home}` |

### Parametric Constructors

| Constructor | Behavior |
|-------------|----------|
| `den.lib.parametric` | owned + statics + `atLeast`-matching includes |
| `den.lib.parametric.atLeast` | Only parametric functions (no owned/statics) |
| `den.lib.parametric.exactly` | Only exact-match functions |
| `den.lib.parametric.fixedTo attrs aspect` | Always uses given attrs as context |
| `den.lib.parametric.expands attrs aspect` | Extends received context with attrs before dispatch |
| `den.lib.parametric.withOwn` | Low-level: `functor: self -> ctx -> aspect` |

### Conditional Application

| Function | Behavior |
|----------|----------|
| `den.lib.take.atLeast fn ctx` | Calls `fn ctx` if args satisfied (`atLeast`), else `{}` |
| `den.lib.take.exactly fn ctx` | Calls `fn ctx` if args exactly match, else `{}` |
| `den.lib.take.unused` | `_unused: used: used` — discards `aspect-chain` |

### Argument Introspection

| Function | Behavior |
|----------|----------|
| `den.lib.canTake params fn` | `true` if fn's args satisfied by params (`atLeast`) |
| `den.lib.canTake.exactly params fn` | `true` only if fn's args exactly match params |

### Extraction / Misc

| Function | Behavior |
|----------|----------|
| `den.lib.statics aspect {class, aspect-chain}` | Extract static includes only |
| `den.lib.owned aspect` | Extract owned configs (removes includes, __functor) |
| `den.lib.isFn val` | `true` if value is a function or has `__functor` |
| `den.lib.isStatic fn` | `true` if fn can take `{class, aspect-chain}` |
| `den.lib.__findFile` | Angle bracket resolver |
| `den.lib.aspects` | Full flake-aspects API |

---

## Three Kinds of Includes

| Kind | Form | When runs |
|------|------|-----------|
| Static attrset | `{ nixos.foo = 1; }` | Always |
| Static leaf | `{ class, aspect-chain }: { ${class}.foo = 1; }` | Once; gets class name |
| Parametric | `{ host, user }: { ... }` | Only when context matches args |

**Context function signatures:**

```nix
# Best: static owned config (no module arg needed)
nixos.networking.firewall.enable = true;

# When you need pkgs/lib/config: function form
nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.vim ]; };

# Parametric in includes — runs when {host} present
# Prefer: den.lib.perHost
den.lib.perHost ({ host }: { nixos.networking.hostName = host.hostName; })

# Parametric in includes — runs when {host, user} present
# Prefer: den.lib.perUser
den.lib.perUser ({ host, user }: { nixos.users.users.${user.userName}.extraGroups = ["wheel"]; })

# Parametric in includes — runs when {home} present
den.lib.perHome ({ home }: { homeManager.home.username = home.userName; })
```

---

## Context Pipeline

```
den.hosts declaration
  │
  ├─► den.ctx.host {host}
  │     - _.host:  fixedTo {host} on host.aspect   (owned + statics + parametric)
  │     - _.user:  atLeast {host,user} on host.aspect  (parametric only)
  │     │
  │     ├─► into.user → den.ctx.user {host, user}  (per user)
  │     │     - _.user: fixedTo {host,user} on user.aspect
  │     │
  │     ├─► into.hm-host → den.ctx.hm-host {host}  (if HM enabled + HM users)
  │     │     - imports home-manager OS module
  │     │     - into.hm-user → den.ctx.hm-user {host, user}
  │     │           - forwards homeManager class → home-manager.users.<userName>
  │     │
  │     ├─► into.wsl-host   (if host.wsl.enable)
  │     ├─► into.hjem-host  (if hjem enabled + hjem users)
  │     └─► into.maid-host  (if maid enabled + maid users)
  │
  ├─► Deduplication
  │     First occurrence: fixedTo (owned + statics + parametric)
  │     Subsequent:       atLeast  (parametric only — no duplicate owned)
  │
  └─► Output: nixosConfigurations / darwinConfigurations / homeConfigurations
```

Standalone `den.homes` entries bypass host processing — apply `fixedTo {home}` directly.

**IMPORTANT (commit #293):** Host-aspect config does NOT auto-flow into HM user envs without `den._.bidirectional`. The `homeManager = _: {...}` owned configs apply at `ctx.hm-host` with `{host}` context (shared config for ALL users). For per-user host→home contribution, use bidirectionality explicitly.

---

## Home Manager Integration

Activation requires:
1. `home-manager.enable = true` on the host
2. At least one user with `"homeManager"` in `classes`
3. `inputs.home-manager` in flake inputs

```nix
# Global default (put in home-manager.nix or schema.nix)
den.schema.user.classes = lib.mkDefault [ "homeManager" ];

# Per host
den.hosts.x86_64-linux.laptop.home-manager.enable = true;

# Per user override
den.hosts.x86_64-linux.laptop.users.bob.classes = [ "homeManager" "hjem" ];
```

Flow: `ctx.hm-host` detects HM-enabled hosts → imports `home-manager.nixosModules.home-manager` → `ctx.hm-user` forwards each user's `homeManager` class into `home-manager.users.<userName>`.

---

## Bidirectionality

**Den docs note: Advanced feature, not recommended unless needed.**

### Built-in (`den._.bidirectional`)

Makes a host contribute config to its users' home environments:

```nix
den.aspects.alice.includes = [ den._.bidirectional ]; # per user
den.ctx.user.includes      = [ den._.bidirectional ]; # all users
```

When active, `igloo.includes` is called TWICE — once with `{host}`, once with `{host, user}`. **Must use guards:**

```nix
# Only in host context:
(den.lib.perHost ({ host }: { nixos.networking.hostName = host.hostName; }))

# Only in user context:
(den.lib.perUser ({ host, user }: { homeManager.programs.vim.enable = true; }))
```

### Mutual Provider (`den._.mutual-provider`)

Explicit named host↔user pairing:

```nix
den.default.includes = [ den._.mutual-provider ];

den.aspects.igloo.provides.tux = { user, ... }: {
  homeManager.programs.helix.enable = true;
};
den.aspects.tux.provides.igloo = { host, ... }: {
  nixos.programs.nh.enable = true;
};
```

---

## Custom Nix Classes (`den._.forward`)

```nix
{ den, lib, ... }:
let
  gitClass = { class, aspect-chain }:
    den._.forward {
      each       = lib.singleton true;
      fromClass  = _: "git";
      intoClass  = _: "homeManager";
      intoPath   = _: [ "programs" "git" ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs  = lib.id;
    };
in {
  den.ctx.user.includes = [ gitClass ];
}
# Usage: den.aspects.alice.git.userEmail = "alice@example.com";
```

**`forward` parameters:**

| Parameter | Description |
|-----------|-------------|
| `each` | Items to iterate (`lib.singleton true`, users, roles) |
| `fromClass` | Source class name |
| `intoClass` | Target class |
| `intoPath` | Attribute path in target |
| `fromAspect` | Aspect to read from |
| `guard` | `{ options, ... } -> bool` — skip if false |
| `adaptArgs` | Transform module args before forwarding |
| `adapterModule` | Custom module for forwarded submodule |

**Built-in forward classes:**
- `user` → `users.users.<userName>` (nixos/darwin)
- `homeManager` → `home-manager.users.<userName>`
- `hjem` → `hjem.users.<userName>`
- `maid` → `users.users.<userName>.maid`
- `os` → both `nixos` AND `darwin` simultaneously (no path)

---

## Custom Context Types

```nix
{ den, lib, ... }: {
  den.ctx.gpu-host = {
    description = "GPU-accelerated host";
    _.gpu-host   = { host }: { nixos.hardware.nvidia.enable = true; };
  };
  den.ctx.host.into.gpu-host = { host }:
    lib.optional (host ? gpu) { inherit host; };
}
# Activates automatically when host has `gpu` attribute.
```

---

## Namespaces

```nix
{ inputs, den, ... }: {
  imports = [
    (inputs.den.namespace "myorg" true) # true = export as flake.denful.myorg
    # false = local only
    # [ inputs.team-config ] = merge from upstream
  ];
  myorg.bluetooth = { nixos.hardware.bluetooth.enable = true; };
  myorg.gaming    = { includes = [ myorg.bluetooth ]; nixos.programs.steam.enable = true; };
}
```

### Angle Brackets

Enable: `_module.args.__findFile = den.lib.__findFile;`

Resolution: `<aspect>` → `den.aspects.aspect`, `<aspect/sub>` → `den.aspects.aspect.provides.sub`, `<namespace>` → `den.ful.namespace`

```nix
den.aspects.laptop.includes = [ <tools/editors> <alice/work-vpn> <den.provides.primary-user> ];
```

---

## Breaking Changes (commits `2f1eace` → `e62bc38`)

| Commit | Change | Impact |
|--------|--------|--------|
| `0def158d` | Split `nix/lib.nix` → `nix/lib/` | Internal restructure |
| `d68155ea` | HM no-bidir fix | **BREAKING**: host-aspect homeManager no longer auto-flows to HM users without `den._.bidirectional` |
| `e62bc38b` | bidir uses `fixedTo` | bidir now includes owned + statics (was atLeast only) |

Our config was pinned to `2f1eace` after this broke. Our `homeManager = ...` owned configs apply via `ctx.hm-host` with `{host}` context and are NOT affected by #293 — they're shared config, not per-user bidir.

---

## Debugging

```nix
{ den, ... }: { flake.den = den; } # temporarily expose
```

```console
nix repl
:lf .
den.aspects.laptop
nixosConfigurations.laptop.config.networking.hostName
```

**Always build with `--show-trace`.** Use `nix eval` for expression inspection, never interactive repl.

**Common issues:**
- Duplicate list values → `den.lib.take.exactly` in `den.default.includes`
- Wrong class → Darwin is `"darwin"` not `"nixos"`
- `den.provides.home-manager` used → DEPRECATED, remove; use `home-manager.enable = true`
- Module not found → check for `_` prefix (excluded from import-tree)

---

## CI Tests (Best Learning Resource)

`github.com/vic/den/tree/main/templates/ci/modules/features/`

Key files: `parametric.nix`, `user-host-bidirectional-config.nix`, `forward.nix`, `namespaces.nix`, `angle-brackets.nix`, `schema-base-modules.nix`, `context/custom-ctx.nix`, `home-manager/home-managed-home.nix`

```console
nix flake check --override-input den . ./templates/ci
```

---

## Quality Checklist

- [ ] No `mkIf` inside aspects
- [ ] No anonymous functions in `includes` — all named
- [ ] Static class data uses attrset form (`nixos.foo = val`), not `nixos = _: { foo = val; }`
- [ ] `den.schema.*` defines shared typed options
- [ ] `den.default` has `stateVersion` for all relevant classes
- [ ] Batteries used instead of manual equivalents
- [ ] `bidirectional`/`mutual-provider` only when needed (advanced feature)
- [ ] `perHost`/`perUser` guards on bidir aspects
- [ ] One file per concern in `modules/`

---

## Dependencies

| Dependency | Purpose |
|-----------|---------|
| `flake-aspects` | Aspect composition primitives |
| `import-tree` | Recursive module auto-discovery (`_` prefix = excluded) |
| `flake-file` | Inline flake input declarations per-module |
| `nixpkgs` | Package collection |
| `home-manager` | User environment management (optional) |
| `flake-parts` | Flake composition (recommended) |
