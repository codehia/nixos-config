# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
just install         # build and apply
just test            # activate temporarily, no boot entry
just dry             # preview what would change, nothing applied
just debug           # apply with full trace (good for debugging build failures)
just up              # update all flake inputs and rebuild
just upp i=NAME      # update one input, e.g. just upp i=home-manager
just clean           # garbage collect old generations
just write-flake     # regenerate flake.nix after adding/removing flake inputs
just history         # list past generations
just repl            # open a NixOS REPL against the current flake
```

> Never use `nix eval` or `nix repl` directly — it causes a RAM spike. Use `just dry` to check.

`devenv.nix` provides a dev shell with Lua/Nix LSPs and git hooks (stylua for `.lua`, nixfmt for `.nix`). Enter it via `devenv shell` or direnv.

If a tool is missing from PATH, use `nix shell nixpkgs#<tool>` rather than installing globally.

## Architecture

This config uses the **dendritic pattern** — features are defined once and composed into hosts/users. It is built on [den](https://github.com/vic/den), [flake-parts](https://github.com/hercules-ci/flake-parts), and [import-tree](https://github.com/vic/import-tree).

### Critical structural facts

- **`flake.nix` is auto-generated.** Never edit it. Flake inputs are declared inline inside modules using `flake-file.inputs.<name>`. After adding or changing any input, run `just write-flake`.
- **`import-tree` auto-discovers** every `.nix` file under `modules/` via git. Files or directories prefixed with `_` are excluded. **New files must be `git add`-ed before building** — unstaged files are invisible to the build.
- **No `specialArgs`/`extraSpecialArgs`** needed. The unstable package set is available everywhere as `pkgs.unstable.*` via an overlay defined in `schema.nix`.

### Module layout

```
modules/
├── den.nix         # bootstraps den + flake-file + flake-parts; sets systems
├── schema.nix      # applies unstable overlay; enables homeManager class for all users
├── defaults.nix    # den.default applied to every host and user
├── hosts/          # one directory per host (personal/, thinkpad/, workstation/, raspberrypi/)
├── users/          # one file per user (deus.nix, soumya.nix)
└── aspects/        # all feature modules — one concern per file
```

### How hosts work

Each `modules/hosts/<hostname>/default.nix` does two things:

**1. Declares the host** (`den.hosts.x86_64-linux.<name>`) with freeform attrs:

```nix
den.hosts.x86_64-linux.thinkpad = {
  home-manager.enable = true;
  wm = "swayfx";              # picked up by deus.nix wmSelector
  greetdUser = "deus";
  greetdSessionBin = "sway";
  nhCleanEnabled = true;
  isLaptop = true;
  nvimLanguages = [ "lua" "nix" "python" "typescript" ];
  gpuKey = "1002:7340-...";   # used by lact.nix perHost
  extraAspects = [ "hyprland" "rclone" ];  # deus gets these on this host only
  users.deus = { personalApps = true; };
  users.soumya = { nvimLanguages = [ "nix" "lua" ]; };
};
```

**2. Defines the host aspect** (`den.aspects.<name>`) with system config and `includes`:

```nix
den.aspects.thinkpad = {
  nixos = { ... }: {
    imports = [ ./_hardware-configuration.nix ./_disko-config.nix ];
    time.timeZone = "Asia/Kolkata";
  };
  includes = [
    den.aspects.nix-config
    den.aspects.networking
    den.aspects.boot
    den.aspects.pipewire
    den.aspects.greetd
    den.aspects.fonts
    # ...
  ];
};
```

Hardware and disko configs are `_`-prefixed and imported explicitly inside `nixos.imports`.

### How aspects work

An aspect has up to three fields:

```nix
den.aspects.example = {
  nixos      = { pkgs, config, ... }: { /* NixOS module */ };
  homeManager = { pkgs, ... }: { /* home-manager module */ };
  includes   = [ den.aspects.other den.aspects.another ];
};
```

Prefer the **attrset form** for static config (no `pkgs`/`lib`/`inputs` access needed):

```nix
den.aspects.foo = {
  nixos.services.foo.enable = true;
  homeManager.programs.foo.enable = true;
};
```

Use the function form only when you need `pkgs`, `lib`, `config`, or `inputs`.

**Multiple files can define the same aspect name** — den merges them (collector pattern). Used by `hyprland/`, `swayfx/`, `nvim/`, `shell-tools/`, `system/`, etc.

### User aspects and selectors

`modules/users/deus.nix` defines `den.aspects.deus`. Two dynamic selectors inside it:

- `wmSelector` — includes `den.aspects.${host.wm}` (picks the WM from the host declaration)
- `extraAspectsSelector` — includes any aspects listed in `host.extraAspects`

To add a feature to deus on **all hosts**: add it to `includes` in `deus.nix`.
To add a feature on **one specific host only**: add the aspect name to `extraAspects` in that host's declaration.

`soumya.nix` hardcodes `den.aspects.hyprland` (not dynamic — no `wmSelector`).

### `den.lib` utilities

```nix
# Config that varies by host — always use a named let-binding, never inline anonymous functions
let
  gpuConfig = { host, ... }:
    lib.optionalAttrs (host ? gpuKey) {
      nixos.services.lact.settings.gpus.${host.gpuKey}.fan_control_enabled = true;
    };
in
den.aspects.lact = {
  includes = [ (den.lib.perHost gpuConfig) ];
};

# Config that runs per user
let
  sshKeys = { user, ... }: { ... };
in
den.aspects.ssh = {
  includes = [ (den.lib.perUser sshKeys) ];
};

# Allow unfree packages
includes = [ (den._.unfree [ "mullvad" "mullvad-vpn" ]) ];
```

**Context IS the condition.** Never use `mkIf` to check host/user attrs inside aspects. A function `{ host, ... }:` is automatically skipped in contexts that don't have `host`.

**Critical:** `den.lib.perUser` inside a **host aspect**'s `includes` is silently ignored — host-aspect includes run in `{ host }` context only. To contribute per-user `nixos` config from a feature aspect, put the `perUser` in `den.default.includes`, or put it in a user aspect's `includes`.

### Context pipeline

```
den.hosts.x86_64-linux.personal.users.deus = {}
    → [host context] den.aspects.personal + den.default applied
        → [user context] den.aspects.deus applied
            → [hm-user context] homeManager.* forwarded to home-manager.users.deus
Output: flake.nixosConfigurations.personal
```

HM activates only when: (1) `home-manager.enable = true` on the host, (2) `den.schema.user.config.classes = ["homeManager"]` in schema.nix (already set), and (3) user declared in `host.users.*`.

### Parametric dispatch mechanics

Den uses `builtins.functionArgs` introspection to decide whether to call a function in a given context. A function is included only when all its **non-defaulted** arguments are present:

- `{ host, ... }` → matches any context containing `host` (atLeast)
- `{ host, user }` → matches only when both are present (atLeast)
- `{ host, user, ... }` → same as above

`den.lib.perHost` uses `take.exactly { host }` — it fires in host contexts and is **silently skipped** in user contexts (even though user contexts also have `host`). Use `den.lib.perUser` for `{ host, user }` contexts.

There are three kinds of things that can appear in `includes`:

1. **Static attrset** `{ nixos.foo = 1; }` — always merged unconditionally
2. **Static leaf** `{ class, aspect-chain }: ...` — evaluated once during resolution, not per-context
3. **Parametric function** `{ host, ... }: ...` — evaluated per context, skipped when args missing

### `den.default` gotcha

`den.default` is applied to every pipeline stage (host, user, hm-user). Owned configs (e.g., `den.default.nixos.foo`) are **deduplicated** across stages. But parametric functions in `den.default.includes` run at **every** stage — wrap them in `den.lib.perHost`/`den.lib.perUser` to restrict:

```nix
den.default.includes = [
  (den.lib.perUser trustedUsers)   # runs only in user contexts
  (den.lib.perHost hostDefaults)   # runs only in host contexts
  den.aspects.someFeature          # static — deduplicated fine
];
```

### `den.schema` tiers

`schema.nix` uses four tiers:

| Option | Applied to |
|--------|-----------|
| `den.schema.conf` | ALL hosts, users, and homes |
| `den.schema.host` | All hosts (imports conf) |
| `den.schema.user` | All users (imports conf) |
| `den.schema.home` | All standalone homes (imports conf) |

Schema declares **typed options** (`lib.mkOption`) and sets defaults (`lib.mkDefault`). Aspects then read those values from `host.*` / `user.*`. This is how `wm`, `nvimLanguages`, etc. are declared in `schema.nix` and read by aspects.

### Mutual providers

`den._.mutual-provider` is already enabled via `den.ctx.user.includes` in this config. It enables bidirectional host↔user config via `provides.*`:

```nix
# Host → all its users (e.g., inject per-host HM config from the host aspect)
den.aspects.thinkpad._.to-users.homeManager.programs.foo.enable = true;

# Host → specific user
den.aspects.thinkpad._.alice.homeManager.programs.vim.enable = true;

# User → all hosts they live on
den.aspects.deus._.to-hosts.nixos.programs.bar.enable = true;

# User → specific host
den.aspects.deus._.thinkpad.nixos.programs.baz.enable = true;
```

`_.` is shorthand for `.provides.`. The `provides` namespace is also how sub-aspects work: `den.aspects.foo._.bar` exposes a named sub-aspect usable as `den.aspects.foo._.bar` in `includes`.

### Built-in Nix classes

Beyond `nixos` and `homeManager`, den has built-in classes:

| Class | Where it forwards |
|-------|------------------|
| `user` | `users.users.<userName>` on the OS — shorthand for NixOS user account config |
| `os` | Both `nixos` and `darwin` simultaneously — for cross-platform system config |

Example using `user` class:
```nix
den.aspects.deus = {
  user.isNormalUser = true;
  user.extraGroups = [ "wheel" "audio" "video" ];
  # equivalent to: nixos.users.users.deus.isNormalUser = true; etc.
};
```

### Batteries reference

All batteries live in `modules/aspects/provides/`. The ones active or relevant in this config:

| Battery | Usage in this config | Effect |
|---------|---------------------|--------|
| `den._.define-user` | `den.default.includes` | Creates `users.users.<name>` + sets HM username/homeDir |
| `den._.hostname` | `den.default.includes` | Sets `networking.hostName` from `host.hostName` |
| `den._.primary-user` | `den.aspects.deus/soumya.includes` | Adds wheel group, uid 1000 |
| `den._.user-shell "fish"` | `den.aspects.deus/soumya.includes` | Sets login shell at OS + HM |
| `den._.mutual-provider` | `den.ctx.user.includes` | Host↔user bidirectional config |
| `den._.unfree ["pkg"]` | aspect `includes` | Allowlists specific unfree packages |
| `den._.inputs'` | `den.default.includes` | Exposes system-specialized `inputs'` as module arg |
| `den._.tty-autologin "user"` | host `includes` | TTY1 autologin (NixOS) |

## Theming

Catppuccin Mocha is applied via two systems:

- **stylix** — fonts, cursor, base16 color schemes, zen-browser, most apps
- **catppuccin/nix** — apps with better purpose-built modules: fish, bat, fzf, lazygit, ghostty, kitty, rofi, kvantum

When adding theming for a new app, check `appearance.nix` first — many targets are explicitly disabled on one system because the other handles it. Do not enable both for the same app.

`stylix.targets.fzf.enable = false` — the catppuccin fzf module handles it instead.

## Secrets (sops-nix + age)

SOPS encrypts values in YAML files while leaving keys in plaintext — safe to commit.

Each host decrypts secrets using its **SSH host key** — no manual age key bootstrap needed.
- NixOS sops-nix: `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]`
- HM sops-nix: `sops.age.sshKeyPaths = [ "~/.ssh/id_ed25519" ]`

The age public keys in `.sops.yaml` are derived from each machine's SSH host key via `ssh-to-age`. On a fresh install, NixOS auto-generates the SSH host key on first boot; sops-nix picks it up automatically.

**Edit an existing secrets file:**
```bash
sops secrets/deus.yaml    # decrypts, opens $EDITOR, re-encrypts on save
# or if sops isn't in PATH:
nix shell nixpkgs#sops -c sops secrets/deus.yaml
```

**After adding a new recipient to `.sops.yaml`:**
```bash
sops updatekeys secrets/common.yaml
```

**Adding a new host:**
1. Install NixOS and boot — SSH host key is auto-generated
2. Get the age public key: `cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age`
3. Add it to `.sops.yaml` with a YAML anchor
4. `sops updatekeys` on any shared secrets files (common.yaml, deus.yaml, etc.)
5. `just install` on the new host — no age key file to restore

The `ssh.nix` aspect is **conditional** — it uses `builtins.pathExists "secrets/<username>.yaml"` to activate per user.

## Adding a new flake input

Declare it inside the relevant module file, then regenerate:

```nix
flake-file.inputs.my-input = {
  url = "github:owner/repo";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```

```bash
just write-flake    # regenerates flake.nix — commit both files together
```

## Adding a new aspect

1. Create the file and stage it:
   ```bash
   git add modules/aspects/myapp.nix
   ```
2. Write the aspect (attrset form preferred):
   ```nix
   { den, ... }:
   {
     den.aspects.myapp = {
       homeManager = { pkgs, ... }: {
         home.packages = [ pkgs.myapp ];
       };
     };
   }
   ```
3. Add it to the relevant `includes` in a user or host aspect.

## Adding a package

**User package** (home-manager, specific user only):
```nix
homeManager.home.packages = with pkgs; [ btop pkgs.unstable.some-new-app ];
```

**System package** (all users on that host):
```nix
nixos.environment.systemPackages = [ pkgs.htop ];
```

For host-specific packages, put them directly in the host's `nixos` block rather than creating a shared aspect.

## Neovim

Stack: `nix-wrapper-modules` (`wlib.evalPackage`) + `lze` (lazy loader) + native Neovim 0.11 LSP API.
`block_normal_config = true` — `~/.config/nvim` is ignored; all config is in `modules/aspects/nvim/`.

**Adding a plugin:**

1. Add to `_plugins.nix`: `hardtime = { data = pkgs.vimPlugins.hardtime-nvim; lazy = true; };`
2. Find the exact pname (packpath dir name — doesn't always match nixpkgs attr):
   ```bash
   find /nix/store -maxdepth 3 -name "vimplugin-*hardtime*" -type d
   # → ...vimplugin-hardtime.nvim-2024-11-25  →  pname = hardtime.nvim
   ```
3. Add a Lua spec in `lua/plugins/` using the pname as `[1]`:
   ```lua
   { 'hardtime.nvim', event = 'VeryLazy', after = function() require('hardtime').setup() end }
   ```
4. `just install`

Common pname gotchas: `snacks-nvim` → `snacks.nvim`, `markview-nvim` → `markview.nvim`, `telescope-nvim` → `telescope.nvim`, `nvim-lspconfig` → `nvim-lspconfig`.

**Adding an LSP / language tool:**

1. Add a block to `_lang-defs.nix` with `packages`, `formatters`, and `linters`.
2. Add the language name to `nvimLanguages` in the host declaration (overridable per user: `users.soumya.nvimLanguages = [...]`).
3. Add LSP config to `lua/config/lsp.lua` guarded by `nix(false, 'categories', 'language')`.

**Nix → Lua bridge:**
```lua
local nix = require(vim.g.nix_info_plugin_name)
local hasPython = nix(false, "categories", "python")   -- always use function form
local formatters = nix({}, "formatters", "fast")
```

## Troubleshooting

### Ghostty service fails with `Result: protocol`

A stray Ghostty process holds the D-Bus name. Fix:
```bash
pkill ghostty
systemctl --user start app-com.mitchellh.ghostty.service
```
Always launch Ghostty via the service, never directly from a shell.

### Ghostty shows random black/blank rows

Stale fontconfig cache after `just clean`. Fix:
```bash
fc-cache -f
systemctl --user restart app-com.mitchellh.ghostty.service
```

### HM config silently dropped

Check that `den.schema.user.config.classes = lib.mkDefault ["homeManager"]` is set in `schema.nix`. Without it, all `homeManager.*` config is silently ignored.

### New `.nix` file not picked up by build

`import-tree` uses git for discovery. Run `git add <file>` before building.

## Consulting den source

When the CLAUDE.md doesn't cover something, consult den directly. The most authoritative reference is the **CI test suite** — every feature has a self-contained, evaluated test:

| Source | What it contains |
|--------|-----------------|
| `wiki/Den-Framework.md` | API reference for this config's usage |
| `wiki/Dendritic-Pattern.md` | All seven aspect patterns with examples |
| `notes/den.md` (if present) | Full den option/battery reference |
| den CI tests — `templates/ci/modules/features/` | **Most authoritative** — every feature as a working nix-unit test |
| [den docs](https://den.oeiuwq.com) | User-facing explanation + guides |

Do not guess at den API shapes — look them up. `den.lib.perHost`, `den.lib.perUser`, `den.lib.parametric`, battery names, and context types are all versioned and can change.

**To read the den source, clone it to `/tmp`** — do not use `nix eval`, do not try to read from `/nix/store`, and do not fetch URLs directly:

```bash
git clone https://github.com/vic/den /tmp/den
# Then read files directly, e.g.:
# /tmp/den/templates/ci/modules/features/parametric.nix
# /tmp/den/modules/aspects/provides/forward.nix
# /tmp/den/docs/src/content/docs/reference/lib.mdx
```

The same applies to any other dependency you need to inspect (home-manager options, sops-nix internals, nix-wrapper-modules, etc.) — clone to `/tmp` and read from there.

## Style rules

| Do | Don't |
|----|-------|
| Attrset form for static config | Anonymous functions in `includes` |
| Named `let`-bindings for parametric includes | `mkIf` for host/user conditions inside aspects |
| `den.lib.perHost`/`perUser` for parametric dispatch | `den.provides.home-manager` (deprecated — use `home-manager.enable = true` on host) |
| `lib.optionalAttrs` for conditional inclusion | `nix eval` / `nix repl` directly |
| `pkgs.unstable.*` for unstable packages | `nix` or `nix shell` when the tool is in PATH |
| `git add` new files before building | Editing `flake.nix` by hand |
| `perUser` in user-aspect `includes` for per-user nixos config | `perUser` in host-aspect `includes` (silently ignored) |
| `den.default.includes` for global per-user nixos config | Assuming `den.default` owned config runs once (it deduplicates) |
| Clone dependency repos to `/tmp` to read source | `nix eval`, reading from `/nix/store`, or fetching URLs to inspect source |
| Look up den API in source/wiki before guessing | Guessing battery names, context types, or parametric variants |
