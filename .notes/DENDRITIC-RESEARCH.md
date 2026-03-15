# Dendritic Migration Research

Comprehensive research covering flake-parts, the dendritic pattern, dendrix, the dendritic design guide, flake-file, and the den library — compiled as a reference for migrating this NixOS configuration.

---

## 1. Flake-Parts Foundation

### What It Is

flake-parts brings the NixOS module system to flakes. Instead of manually writing `forAllSystems` boilerplate, you decompose `flake.nix` into composable modules — each receiving `{ config, lib, inputs, ... }` just like NixOS modules.

### mkFlake Entry Point

```nix
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ /* flake-parts modules */ ];
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { config, pkgs, system, inputs', self', ... }: {
        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell { buildInputs = [ pkgs.nixfmt ]; };
      };

      flake = {
        # Non-system-specific outputs: nixosConfigurations, etc.
      };
    };
```

The argument to `mkFlake` is `{ inherit inputs; }`, followed by a **top-level module** (attrset or function).

### Top-Level Module Arguments

| Argument | Description |
|---|---|
| `config` | Merged result of all option definitions from all modules |
| `options` | Option declarations for the current scope |
| `lib` | Nixpkgs library functions |
| `inputs` | Your flake inputs (passed to `mkFlake`) |
| `self` | The flake's self reference |
| `getSystem` | `getSystem "x86_64-linux"` returns that system's `perSystem` config |
| `withSystem` | Enters a system's scope: `withSystem "x86_64-linux" ({ pkgs, config, ... }: ...)` |
| `moduleWithSystem` | Brings `perSystem` args into a module without global variables |

### perSystem

Writes system-dependent outputs once; flake-parts iterates over the `systems` list:

```nix
perSystem = { pkgs, ... }: {
  packages.hello = pkgs.hello;  # becomes packages.x86_64-linux.hello, etc.
};
```

**perSystem arguments:** `pkgs`, `system`, `inputs'` (inputs with system pre-selected), `self'`, `config`, `lib`.

Critical: You **must** explicitly name parameters in function signatures (`{ pkgs, inputs', ... }:`), not use `args:` syntax, because the module system uses `builtins.functionArgs`.

### Available perSystem Options

| Option | Description |
|---|---|
| `packages` | `nix build .#<name>` |
| `devShells` | `nix develop .#<name>` |
| `checks` | `nix flake check` |
| `apps` | `nix run` |
| `formatter` | `nix fmt` |
| `legacyPackages` | Arbitrary nested attribute sets |

### flakeModules

Export reusable flake-level logic for other flakes to import:

```nix
flake.flakeModules.default = { config, lib, ... }: {
  # Module options and config for consumers
};
```

### Splitting Into Files

When extracting code to separate files, you lose lexical scope. Two solutions:

**Bridge options** — define options in the module, set them from flake.nix:

```nix
# ./modules/my-module.nix
{ lib, config, ... }: {
  options.services.foo.package = lib.mkOption { type = lib.types.package; };
  config = { /* use config.services.foo.package */ };
}
```

**importApply** — pass extra arguments to a file that returns a module:

```nix
{ flake-parts-lib, self, withSystem, ... }:
let inherit (flake-parts-lib) importApply; in {
  flake.nixosModules.default =
    importApply ./nixos-module.nix { localFlake = self; inherit withSystem; };
}
```

### Key Built-In Top-Level Options

| Option | Type | Description |
|---|---|---|
| `systems` | list of strings | Platforms to enumerate |
| `perSystem` | module | Per-system configuration |
| `flake` | attrset | Raw flake output attributes |
| `flakeModules` | attrset of modules | Exportable flake modules |
| `nixosModules` | attrset of modules | Exportable NixOS modules |
| `nixosConfigurations` | attrset | NixOS system configs |

---

## 2. The Dendritic Pattern

### Core Principle

> **Every `.nix` file (except `flake.nix`) is a flake-parts module of the same top-level configuration.**

The name "dendritic" refers to tree-like branching: a single root (the flake-parts evaluation) branches into features, each touching multiple configuration levels.

### The Paradigm Shift

**Traditional (top-down, host-centric):**
```
myHost1 (NixOS) -> has services, apps, home-manager settings
myHost2 (NixOS) -> has services, apps, home-manager settings
```

**Dendritic (bottom-up, feature-centric):**
```
featureX contains:
  - NixOS settings
  - Darwin settings
  - Home-Manager settings
featureX -> used on myHost1, myHost2, myHost3
```

### Key Terms

- **`<class>`** — type of configuration: `nixos`, `darwin`, `homeManager`, `generic`
- **`<aspect>`** — cross-cutting concern or feature: `ssh`, `bluetooth`, `cli-tools`

### Three Architectural Layers

**Layer 1: flake.nix** — minimal, just sets up flake-parts + auto-imports all modules:

```nix
{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

**Layer 2: Infrastructure modules** — plumbing that connects flake-parts to lower-level systems. E.g., `configurations/nixos.nix` declares a `configurations.nixos` option and maps entries into `flake.nixosConfigurations` via `lib.nixosSystem`.

**Layer 3: Feature modules** — each file implements a single feature across all configuration classes it applies to.

### The `flake.modules` Mechanism

The backbone. Provided by `flake-parts.flakeModules.modules`, it stores deferred modules organized by class:

```nix
# Enable it:
{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
```

Then features set values:

```nix
flake.modules.<class>.<aspect> = {
  imports = [ /* other aspects of the same class */ ];
  # module code
};
```

The `deferredModule` type means modules are collected and merged from multiple files before evaluation. Multiple files can define the same `flake.modules.nixos.base` — their values merge automatically.

### No specialArgs

Using `specialArgs` or `extraSpecialArgs` is considered an **anti-pattern**. Since every file is a top-level flake-parts module, shared values are accessed via `config` and `inputs` directly, or via `let` bindings within a feature file.

```nix
# modules/vic.nix
let
  userName = "vic";  # shared between classes via let binding
in {
  flake.modules.nixos.${userName} = {
    users.users.${userName} = { isNormalUser = true; extraGroups = [ "wheel" ]; };
  };
  flake.modules.homeManager.${userName} = { lib, ... }: {
    home.username = lib.mkDefault userName;
    home.homeDirectory = lib.mkDefault "/home/${userName}";
  };
}
```

### Cross-Cutting Features in Single Files

A single file can contribute to multiple configuration classes:

```nix
# modules/ssh.nix
{ inputs, config, ... }:
let scpPort = 2277; in {
  flake.modules.nixos.ssh = {
    services.openssh = { enable = true; openFirewall = true; };
  };
  flake.modules.darwin.ssh = {
    services.openssh.enable = true;
  };
  flake.modules.homeManager.ssh = {
    # ~/.ssh/config, authorized_keys, etc.
  };
}
```

### import-tree (vic/import-tree)

Auto-imports all `.nix` files recursively from a directory. Files/folders with `/_` in the path are excluded. This eliminates manual import lists entirely — adding a new file automatically includes it.

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

### How Hosts Are Defined

Hosts compose which feature aspects to include:

```nix
# modules/myhost/imports.nix
{ config, ... }: {
  configurations.nixos.myhost.module.imports =
    with config.flake.modules.nixos; [ base pc swap ];
}
```

Or using a helper library:

```nix
# modules/hosts/homeserver/flake-parts.nix
{ inputs, ... }: {
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "homeserver";
}

# modules/hosts/homeserver/configuration.nix
{ inputs, ... }: {
  flake.modules.nixos.homeserver = {
    imports = with inputs.self.modules.nixos; [ system-cli systemd-boot ];
  };
}
```

Multiple files can contribute to the same host (hardware, networking, users, services — all merge):

```nix
# modules/hosts/homeserver/hardware.nix
{
  flake.modules.nixos.homeserver = {
    boot.kernelModules = [ "kvm-intel" ];
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
```

### Home-Manager Integration

**Tool setup** — a feature module imports the HM NixOS module:

```nix
# modules/home-manager.nix
{ inputs, ... }: {
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
```

**User features** wire HM imports per-user:

```nix
home-manager.users."${username}" = {
  imports = [ self.modules.homeManager."${username}" ];
};
```

**Feature-level HM** uses `sharedModules`:

```nix
flake.modules.nixos.gnome = {
  home-manager.sharedModules = [ inputs.self.modules.homeManager.gnome ];
};
```

---

## 3. The 8 Aspect Design Patterns

### 3.1 Simple Aspect

Feature used in one or multiple configuration contexts without interdependencies.

```nix
{
  flake.modules.nixos.basicPackages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ git tmux ];
  };
  flake.modules.homeManager.basicPackages = { pkgs, ... }: {
    programs.git.enable = true;
  };
}
```

### 3.2 Multi Context Aspect

Feature in one main context (e.g., NixOS) that also defines mandatory config for a nested context (e.g., Home-Manager). The main module injects the HM module via `sharedModules`.

```nix
{ inputs, ... }: {
  flake.modules.nixos.gnome = {
    home-manager.sharedModules = [ inputs.self.modules.homeManager.gnome ];
    services.xserver.desktopManager.gnome.enable = true;
  };
  flake.modules.homeManager.gnome = {
    dconf.settings."org/gnome/desktop/interface".enable-hot-corners = true;
  };
}
```

### 3.3 Inheritance Aspect

Modify/extend an existing feature. Import the parent, add changes.

```nix
{ inputs, ... }: {
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli       # parent
      printing
    ];
  };
  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli       # parent
      browser
      office
    ];
  };
}
```

Full chain: `system-minimal` -> `system-default` -> `system-cli` -> `system-desktop`

### 3.4 Conditional Aspect

Platform-specific parts within a shared module. Must use `lib.mkMerge`, never `//`. Never use `lib.mkIf` on imports (causes recursion).

```nix
{
  flake.modules.homeManager.office = { pkgs, lib, ... }:
    lib.mkMerge [
      { home.packages = with pkgs; [ pdfarranger ]; }
      (lib.mkIf pkgs.stdenv.isLinux {
        home.packages = with pkgs; [ libreoffice-qt6 ];
      })
    ];
}
```

### 3.5 Collector Aspect

Multiple files contribute to the same aspect (values auto-merge).

```nix
# modules/services/syncthing.nix
{ flake.modules.nixos.syncthing = { services.syncthing.enable = true; }; }

# modules/hosts/homeserver/syncthing.nix  (adds device ID)
{ flake.modules.nixos.syncthing = {
    services.syncthing.settings.devices.homeserver.id = "VNV2XTI-...";
  };
}
```

### 3.6 Constants Aspect

Shared values via `generic` module class with custom options.

```nix
{
  flake.modules.generic.systemConstants = { lib, ... }: {
    options.systemConstants = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };
    config.systemConstants.adminEmail = "admin@test.org";
  };
}
```

Import `systemConstants` from `modules.generic` and access via `config.systemConstants.adminEmail`.

### 3.7 DRY Aspect

Custom module class for reusable attribute assignments within submodule structures.

```nix
# modules/network/subnet-A.nix
{ flake.modules.networkInterface.subnet-A = {
    ipv4.routes = [ { address = "192.168.2.0"; prefixLength = 24; via = "192.168.1.1"; } ];
  };
}

# Usage in a host:
{ self, lib, ... }: {
  flake.modules.nixos.homeserver = {
    networking.interfaces."enp86s0" = with self.modules.networkInterface;
      lib.mkMerge [ subnet-A subnet-B { /* host-specific */ } ];
  };
}
```

### 3.8 Factory Aspect

Generate parameterized module instances from template functions.

```nix
# modules/factory/user.nix
{ self, ... }: {
  config.flake.factory.user = username: isAdmin: {
    nixos."${username}" = { lib, pkgs, ... }: {
      users.users."${username}" = {
        isNormalUser = true;
        extraGroups = lib.optionals isAdmin [ "wheel" ];
        shell = pkgs.fish;
      };
      home-manager.users."${username}".imports = [ self.modules.homeManager."${username}" ];
    };
    homeManager."${username}" = {
      home.username = "${username}";
    };
  };
}

# Usage:
{ self, lib, ... }: {
  flake.modules = lib.mkMerge [
    (self.factory.user "bob" true)
    {
      homeManager.bob = { pkgs, ... }: {
        imports = with self.modules.homeManager; [ system-desktop ];
        home.packages = with pkgs; [ mediainfo ];
      };
    }
  ];
}
```

---

## 4. Helper Library Pattern

A common infrastructure module defines helpers for creating configurations:

```nix
# modules/nix/flake-parts/lib.nix
{ inputs, lib, ... }: {
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          { nixpkgs.hostPlatform = lib.mkDefault system; }
        ];
      };
    };
    mkHomeManager = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager.${name}
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    };
  };
}
```

This makes host definitions one-liners:

```nix
{ inputs, ... }: {
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "thinkpad";
}
```

---

## 5. Dendrix (Community Distribution)

### What It Is

Dendrix is a **community-driven distribution of dendritic Nix configurations** — like NUR but for flake-parts dendritic modules. It enables sharing and reusing aspect-oriented configurations across repositories.

### Layers

Cross-repository flake-parts modules that aggregate aspects from multiple community repositories:

```nix
# Use a community layer
{ inputs, ... }: {
  imports = [ inputs.dendrix.ai ];
}
```

### Import-Trees

Dendrix discovers aspects and classes from community repos, exposing them as importable trees:

```nix
{
  imports = [
    inputs.dendrix.some-repo.some-aspect  # specific aspect from a repo
  ];
}
```

### Conventions

1. **`modules/community`** directory for shared aspects (auto-detected by Dendrix)
2. **`private` in path** — hidden from community, even within `modules/community`
3. **Flags** (`+flag`) for selective inclusion: `inputs.dendrix.repo.flagged "-emacs +vim"`
4. **Clean flake.nix** — logic lives in `./modules`, flake.nix is auto-generated

### Related Tools

| Tool | Purpose |
|---|---|
| `vic/import-tree` | Auto-import all `.nix` files; `/_` excludes |
| `vic/flake-file` | Each module declares its own flake inputs; auto-generates `flake.nix` |
| `vic/dendritic-unflake` | Dendritic without flakes or flake-parts |
| `vic/denful` | Curated "blessed" dendritic modules for reuse |

---

## 6. flake-file (vic/flake-file)

### What It Is

flake-file **generates your `flake.nix` from flake-parts modules**. Each module declares the flake inputs it needs via `flake-file.inputs`, and flake-file aggregates them into a clean, auto-generated `flake.nix`. You stop editing `flake.nix` by hand — it becomes a dependency manifest like `package.json`.

### How It Works

1. Each flake-parts module sets `flake-file.inputs.<name>` options
2. Since these are module options, they support `lib.mkDefault`, `lib.mkForce`, merging across modules
3. Running `nix run ".#write-flake"` evaluates all modules, collects inputs, and writes `flake.nix`
4. A `check-flake-file` derivation in `nix flake check` verifies the checked-in `flake.nix` matches what would be generated

### The `flake-file.inputs` Option

Each key is an input name; values are submodules with fields:

| Field | Type | Description |
|---|---|---|
| `url` | `str` | Source URL |
| `follows` | `str` (nullable) | Follow another input |
| `flake` | `bool` | Whether input is a flake (default `true`) |
| `inputs.<name>.follows` | `str` | Nested follows for transitive deps |
| `type`, `owner`, `repo`, `host`, `path`, `dir`, `id`, `rev`, `ref`, `narHash`, `submodules` | various | Standard flake input fields |

### The `flake-file.outputs` Option

A **literal Nix expression as a string** (not a function — you cannot serialize functions):

```nix
# Default:
flake-file.outputs = ''inputs: import ./outputs.nix inputs'';

# Dendritic template:
flake-file.outputs = lib.mkDefault ''
  inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
'';
```

### Modules Declaring Their Own Inputs

```nix
# modules/home-manager.nix — declares only the input it needs
{ inputs, lib, ... }: {
  flake-file.inputs = {
    home-manager.url = lib.mkDefault "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
  };
}
```

```nix
# modules/catppuccin.nix — declares its own input
{ inputs, lib, ... }: {
  flake-file.inputs = {
    catppuccin.url = lib.mkDefault "github:catppuccin/nix/release-25.11";
    catppuccin.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  flake.modules.nixos.theming = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  };
  flake.modules.homeManager.theming = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];
    catppuccin.flavor = "mocha";
    catppuccin.enable = true;
  };
}
```

```nix
# modules/dendritic-tools.nix — the core infrastructure
{ inputs, lib, ... }: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    import-tree.url = lib.mkDefault "github:vic/import-tree";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';

  systems = [ "x86_64-linux" ];
}
```

### Generated flake.nix Example

```nix
# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix/release-25.11";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-lib.follows = "nixpkgs";
  };
}
```

### Commands

```bash
nix run ".#write-flake"   # Regenerate flake.nix from module declarations
nix flake check           # Verify flake.nix is up-to-date (CI-friendly)
```

### Caveats

1. **`flake-file.outputs` must be a string** — not a Nix function, a literal string of Nix code
2. **Bootstrap chicken-and-egg** — `flake.nix` must exist before Nix can evaluate. Use `nix flake init -t github:vic/flake-file#dendritic` for new projects, or write a minimal bootstrap by hand
3. **Generated file must be committed** — Nix requires `flake.nix` to be tracked in git
4. **No automatic watching** — you must run `write-flake` manually after changing module inputs
5. **`lib.mkDefault` everywhere** — dendritic modules use `lib.mkDefault` so users can override; if you set without `mkDefault` you override them (intended behavior)

---

## 7. Den Library (vic/den)

### What It Is

Den is a reusable, aspect-oriented Dendritic Nix configuration framework. It extends flake-parts with declarative host/user/home definitions, batteries (built-in aspects), and parametric context routing. It replaces the need to manually write infrastructure plumbing (helper libraries, host boilerplate, user factories).

### The Dendritic Ecosystem

| Library | Repository | Purpose |
|---|---|---|
| **import-tree** | `github:vic/import-tree` | Auto-imports `.nix` files from directory trees |
| **flake-file** | `github:vic/flake-file` | Modules declare their own flake inputs |
| **flake-aspects** | `github:vic/flake-aspects` | Core `<aspect>.<class>` transposition and dependency resolution |
| **den** | `github:vic/den` | Declarative hosts/users/homes, batteries, parametric context |
| **denful** | `github:vic/denful` | Blessed reusable dendritic modules (no user/host specifics) |
| **dendrix** | Community | Community-submitted dendritic modules |

### Top-Level Options

```nix
den.hosts.<system>.<hostName> = {
  name = "<hostName>";           # config name (defaults to attr name)
  hostName = "<hostName>";       # network hostname
  system = "<system>";           # platform (auto from parent attr)
  class = "nixos";               # "nixos" or "darwin" (auto-detected from system)
  aspect = "<hostName>";         # which aspect to use (defaults to host name)
  instantiate = <function>;      # defaults to nixpkgs.lib.nixosSystem
  intoAttr = "nixosConfigurations"; # flake output attribute

  users.<userName> = {
    name = "<userName>";
    userName = "<userName>";
    class = "homeManager";
    aspect = "<userName>";       # which aspect to use (defaults to user name)
  };

  # Freeform — add any custom metadata
  isWarm = true;
  wsl = {};
};

den.homes.<system>.<userName> = {
  # Standalone home-manager configurations
  name = "<userName>";
  system = "<system>";
  pkgs = <nixpkgs instance>;
  instantiate = <function>;      # defaults to home-manager.lib.homeManagerConfiguration
  intoAttr = "homeConfigurations";
};

den.base = {
  # ⚠ DEPRECATED — use den.default instead (see below)
  conf = <deferredModule>;       # shared base for ALL configurations
  host = <deferredModule>;       # extends host submodules
  user = <deferredModule>;       # extends user submodules
  home = <deferredModule>;       # extends home submodules
};

den.aspects.<name> = {
  nixos = <module>;              # NixOS-class configuration
  darwin = <module>;             # Darwin-class configuration
  homeManager = <module>;        # Home-Manager-class configuration
  includes = [ <aspects> ];      # dependency declarations
  provides = { <sub-aspects> };  # alias: _
};

den.default = <parametric aspect>;  # applied to ALL hosts/homes (replaces deprecated den.base)
```

### Aspects — The Core Mechanism

Aspects replace `flake.modules` with a richer structure. An aspect is an attrset with:

1. **Owned modules** — direct `nixos`, `darwin`, `homeManager` configs
2. **`provides` (alias `_`)** — nested sub-aspects forming a tree
3. **`includes`** — dependency declarations (other aspects or parametric functions)

```nix
# modules/igloo.nix — a host aspect
{
  den.aspects.igloo = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.hello ];
    };
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}
```

```nix
# modules/tux.nix — a user aspect with batteries
{ den, ... }: {
  den.aspects.tux = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.htop ];
    };
  };
}
```

### Batteries (Built-in Aspects)

| Battery | Description | Example |
|---|---|---|
| **home-manager** | Integrates HM into NixOS/Darwin hosts. Auto-resolves per-user aspects. | Auto-included when users have `homeManager` class |
| **define-user** | Creates user at OS + HM levels (isNormalUser, home.username, homeDirectory) | Auto-included by default |
| **primary-user** | Admin user (wheel group on NixOS, primaryUser on Darwin) | `den.provides.primary-user` |
| **user-shell** | Sets default shell at OS + HM levels. Parametric. | `(den.provides.user-shell "fish")` |
| **unfree** | Enables unfree packages by name. Class-generic. | `(den.provides.unfree ["steam" "discord"])` |
| **import-tree** | Imports non-dendritic `.nix` files by class convention (`_nixos/`, `_homeManager/`). For migration. | `den.provides.import-tree._.host ./hosts` |
| **tty-autologin** | Auto-login for TTY (VMs) | `(den.provides.tty-autologin "tux")` |
| **ci-noboot** | Disables boot for CI testing | `den.provides.ci-noboot` |

### Parametric Aspects and Context

Den's key innovation: aspects receive **context** about where they're being evaluated. The context tells an aspect function which host, user, or home is being built.

**Intent contexts passed to parametric aspects:**

| Context | When | Contains |
|---|---|---|
| `{ OS, host }` | Building OS config for a host | `OS` = host aspect, `host` = host metadata |
| `{ OS, host, user }` | User contributing to host OS config | All three |
| `{ HM, user, host }` | Building HM for a user on a host | `HM` = user aspect |
| `{ HM, home }` | Building standalone HM config | `HM` = home aspect, `home` = home metadata |

```nix
# A parametric aspect that reacts to context
{ den, ... }: {
  den.provides.define-user = den.lib.parametric {
    includes = [
      # Only fires when building for a host user
      ({ host, user, ... }: {
        nixos.users.users.${user.userName}.isNormalUser = true;
        homeManager.home.username = user.userName;
      })
      # Only fires for standalone home
      ({ home, ... }: {
        homeManager.home.username = home.userName;
      })
    ];
  };
}
```

### den.lib API

```nix
den.lib.parametric <aspect>        # Make aspect parametric (responds to context)
den.lib.parametric.atLeast <asp>   # Match context with at least these params
den.lib.parametric.exactly <asp>   # Match only exact context signature
den.lib.parametric.withOwn <f> <a> # Combine owned configs + functor
den.lib.parametric.fixedTo <a> <b> # Fixed-context aspect
den.lib.parametric.expands <a> <b> # Append attrs to received context

den.lib.take.exactly <function>    # Wrap fn to match exact context
den.lib.take.atLeast <function>    # Wrap fn to match at-least context
den.lib.take.unused <ign> <val>    # Ignore first arg, return second

den.lib.owned <aspect>             # Extract only owned modules
den.lib.statics <aspect>           # Extract only static includes
den.lib.isFn <value>               # Test if value is function or has __functor
den.lib.__findFile                  # Enable angle-brackets syntax
```

### Dependency Resolution

When building a host config, Den resolves dependencies automatically:

```nix
# For each host:
#   1. Include den.default owned configs and static includes
#   2. Include host aspect (OS) owned configs and includes
#   3. For each user:
#      - Include user aspect owned configs and includes
#      - Call parametric functions with { OS, host, user } context
#   4. Resolve all includes recursively
#   5. Produce final merged module for lib.nixosSystem
```

### Complete Minimal Example

```nix
# flake.nix (auto-generated by flake-file)
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
  inputs = {
    den.url = "github:vic/den";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-lib.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };
}
```

```nix
# modules/dendritic.nix — infrastructure setup
{ inputs, ... }: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];
  flake-file.inputs = {
    den.url = "github:vic/den";
    flake-file.url = "github:vic/flake-file";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

```nix
# modules/hosts.nix — declare hosts and users
{
  den.hosts.x86_64-linux = {
    thinkpad = { home-manager.enable = true; users.deus = {}; };
    workstation = { home-manager.enable = true; users.deus = {}; };
    personal = { home-manager.enable = true; users.deus = {}; };
  };
}
```

```nix
# modules/thinkpad.nix — host aspect
{ den, inputs, ... }: {
  den.aspects.thinkpad = {
    includes = with den.aspects; [ base-system hyprland-desktop ];
    nixos = {
      imports = [ ./hosts/thinkpad/hardware-configuration.nix ./hosts/thinkpad/disko-config.nix ];
      networking.hostName = "thinkpad";
      services.tlp.enable = true;
    };
  };
}
```

```nix
# modules/deus.nix — user aspect
{ den, ... }: {
  den.aspects.deus = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ ripgrep fzf eza ];
      programs.git.enable = true;
    };
  };
}
```

### Templates

```bash
nix flake init -t github:vic/den           # Default (batteries-included)
nix flake init -t github:vic/den#minimal   # Essentials only
nix flake init -t github:vic/den#noflake   # No flakes, stable Nix with npins
nix flake init -t github:vic/den#example   # Full API demonstrations
```

### Migration Strategy with import-tree Battery

For gradual migration, Den's `import-tree` battery can import existing non-dendritic config files:

```nix
{ den, ... }: {
  den.default.includes = [
    (den.provides.import-tree._.host ./hosts)   # loads ./hosts/<host>/_nixos/
    (den.provides.import-tree._.user ./users)   # loads ./users/<user>/_homeManager/
  ];
}
```

This means you can migrate incrementally — move features to dendritic aspects one at a time while keeping existing config files in `_nixos/` and `_homeManager/` directories.

---

## 8. Den vs Manual Dendritic (flake.modules)

When using Den, you use `den.aspects` and `den.hosts` instead of manually writing `flake.modules` and `flake.nixosConfigurations` plumbing. Here's the comparison:

**Manual dendritic (flake.modules approach from Doc-Steve guide):**
```nix
# modules/hosts/thinkpad/flake-parts.nix — boilerplate
{ inputs, ... }: {
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "thinkpad";
}

# modules/hosts/thinkpad/configuration.nix — composition
{ inputs, ... }: {
  flake.modules.nixos.thinkpad = {
    imports = with inputs.self.modules.nixos; [ system-cli systemd-boot bluetooth ];
  };
}

# modules/ssh.nix — feature
{
  flake.modules.nixos.ssh = { services.openssh.enable = true; };
  flake.modules.homeManager.ssh = { programs.ssh.enable = true; };
}
```

**With Den:**
```nix
# modules/hosts.nix — declare all hosts
{ den.hosts.x86_64-linux.thinkpad.users.deus = {}; }

# modules/thinkpad.nix — aspect (auto-linked by name)
{ den, ... }: {
  den.aspects.thinkpad = {
    includes = with den.aspects; [ system-cli systemd-boot bluetooth ];
    nixos.networking.hostName = "thinkpad";
  };
}

# modules/ssh.nix — feature (uses den.aspects instead of flake.modules)
{
  den.aspects.ssh = {
    nixos.services.openssh.enable = true;
    homeManager.programs.ssh.enable = true;
  };
}
```

Den eliminates: manual `mkNixos` helpers, explicit `flake.nixosConfigurations` wiring, user factory boilerplate, and home-manager NixOS module integration. Batteries like `primary-user`, `user-shell`, `define-user`, and `unfree` handle the most common patterns declaratively.

---

## 9. Key Differences: Current Config vs Dendritic

| Aspect | Current Config | Dendritic |
|---|---|---|
| File semantics | Mixed — NixOS modules, HM modules, Lua files | Uniform — all `.nix` files are flake-parts modules |
| Organization | By config class (`hosts/common/home/`, `hosts/common/nixos/`) | By feature (`git/`, `shells/`, `sudo.nix`) |
| Cross-cutting | Feature split across directories | Single file touches NixOS + HM |
| Value sharing | `specialArgs` / `extraSpecialArgs` with `pkgs-unstable` | Top-level `config` and `let` bindings |
| Imports | Manual import lists in `default.nix` files | Automatic via `import-tree` |
| Host definition | One monolithic `default.nix` per host | Multiple files contribute via `deferredModule` merging |
| flake.nix | ~210 lines with duplicated host blocks | ~5 lines (auto-generated) |
| Adding a feature to a host | Edit host's module imports + create files in correct directories | Add aspect name to host's imports list |
| Removing a feature | Find and remove from multiple files/directories | Remove one import or prefix file with `_` |

---

## 10. Critical Rules and Gotchas

1. **Never `lib.mkIf` on imports** — causes infinite recursion. Make module *content* conditional instead.
2. **No duplicate imports** — avoid importing the same module multiple times in the same hierarchy path.
3. **Type safety** — importing a `nixos` module into `darwin` or `homeManager` causes errors. Use `generic` for cross-class modules.
4. **Use `lib.mkMerge`** not `//` when merging conditional attribute sets.
5. **`builtins.functionArgs`** — flake-parts uses this, so always name your function parameters explicitly.
6. **All features auto-imported but inactive** — aspect definitions in `flake.modules` remain dormant until a host or configuration explicitly imports them.

---

## 11. Reference Resources

**Flake Parts:**
- https://flake.parts/
- https://flake.parts/getting-started
- https://flake.parts/define-module-in-separate-file
- https://flake.parts/options/flake-parts

**Dendritic Pattern:**
- https://github.com/mightyiam/dendritic (pattern definition)
- https://github.com/Doc-Steve/dendritic-design-with-flake-parts (design guide)
- https://vic.github.io/dendrix/Dendritic.html (vic's docs)

**flake-file:**
- https://github.com/vic/flake-file

**Den:**
- https://den.oeiuwq.com/
- https://github.com/vic/den

**flake-aspects:**
- https://github.com/vic/flake-aspects

**Dendrix:**
- https://dendrix.oeiuwq.com/
- https://github.com/vic/dendrix

**Video Tutorials:**
- Vimjoyer: "Elevate Your Nix Config With Dendritic Pattern"
- Vimjoyer: "Break Your Flake Into Parts"

**Reference Implementations:**
- https://github.com/vic/vix
- https://github.com/drupol/infra
- https://github.com/mightyiam/infra

**Search tip:** `lang:nix flake.modules SOME-OPTION` on GitHub to find implementations.
