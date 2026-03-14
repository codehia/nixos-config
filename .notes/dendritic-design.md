# Dendritic Design Pattern — Research Notes

> Researched: 2026-03-14
> Sources: [Doc-Steve/dendritic-design-with-flake-parts](https://github.com/Doc-Steve/dendritic-design-with-flake-parts), [mightyiam/dendritic](https://github.com/mightyiam/dendritic), linked resources

---

## What is the Dendritic Pattern?

The dendritic pattern is **a Nixpkgs module system usage pattern** with one core rule:

> "Every Nix file except for entry points (`default.nix`, `flake.nix`) is a module of the top-level configuration."

Each top-level module must:
1. Implement a **single feature**
2. Apply across **all configurations** where that feature is relevant
3. Be positioned at a path that **names** that feature

The pattern uses a top-level configuration (typically flake-parts) that facilitates declaration and evaluation of lower-level configurations (NixOS, home-manager, nix-darwin).

---

## How It Differs from Traditional NixOS Configs

### Traditional (host-centric):
```
hosts/
  laptop/
    configuration.nix    # All laptop services, packages, users
    hardware.nix
  server/
    configuration.nix    # All server services, packages, users
    hardware.nix
```
- Config is organized **by host** — each host file defines everything for that machine
- Adding a feature means editing each host file
- Cross-platform (NixOS + Darwin) requires heavy conditional logic (`mkIf`)
- Code duplication when multiple hosts share features

### Dendritic (feature-centric):
```
modules/
  fish.nix              # Fish shell config for ALL hosts/users
  catppuccin.nix         # Theme for ALL hosts/users
  hyprland/              # Compositor for applicable hosts
  nvim/                  # Editor for ALL users
  hosts.nix              # Declares which hosts/users exist
```
- Config is organized **by feature** — each file defines one concern across all targets
- Adding a feature = creating one file, it auto-applies where relevant
- Cross-platform = add a `darwin` block alongside `nixos` in same file
- No duplication — one definition serves all hosts

### Key benefits:
- **Reusable code** easily integrated across hosts
- **Simple troubleshooting** — errors are in one location per feature
- **Logical, expandable structure** that minimizes complexity
- **File location independence** — move/rename files freely without breaking code

---

## Key Concepts

### Features
A "feature" encapsulates functionality usable across various configuration environments. Features can represent:
- Individual services/apps (syncthing, firefox)
- Service categories (mailServer, bluetooth)
- Usage domains (desktopEnvironment)
- User or host specs (bob, myServer)
- User/host categories (adminUser, officeNotebook)
- Nix tools (impermanence)

### Aspects
Configuration-context-specific implementations within a feature. One feature may define multiple aspects:
- `nixos` aspect — NixOS system config
- `darwin` aspect — macOS config
- `homeManager` aspect — user environment config
- `generic` aspect — cross-context compatible

### Module Classes
Flake Parts organizes modules by class:
```nix
flake.modules.<module_class>.<aspect_name> = { ... };
```
Classes: `nixos`, `darwin`, `homeManager`, `generic`

### Import Rules
- Module imports must match typed classes (NixOS → NixOS only)
- Cross-context modules use `generic` class
- Imports must remain **unconditional** (no `lib.mkIf` for imports)
- Content can vary conditionally; imports cannot

---

## Eight Aspect Design Patterns

### 1. Simple Aspect
**When:** Optional features usable across multiple contexts without dependencies.
```nix
flake.modules.nixos.basicPackages = { pkgs }: {
  environment.systemPackages = with pkgs; [ vim git ];
};
flake.modules.homeManager.basicPackages = { pkgs }: {
  programs.git.enable = true;
};
```

### 2. Multi Context Aspect
**When:** Features targeting one context but requiring config in nested contexts (e.g., NixOS + Home Manager).
```nix
flake.modules.nixos.gnome = {
  home-manager.sharedModules = [
    inputs.self.modules.homeManager.gnome
  ];
  # system-level gnome config
};
flake.modules.homeManager.gnome = {
  # HM-specific gnome settings
};
```

### 3. Inheritance Aspect
**When:** Extending or modifying existing parent features.
```nix
flake.modules.nixos.system-desktop = {
  imports = with inputs.self.modules.nixos; [
    system-cli    # parent
    mail browser kde
  ];
};
```
**Caution:** Prevent duplicate imports when combining with multi-context aspects.

### 4. Conditional Aspect
**When:** Platform-dependent or condition-dependent configuration.
```nix
flake.modules.homeManager.office = { pkgs, lib, ... }:
lib.mkMerge [
  { home.packages = with pkgs; [ notesnook ]; }
  (lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [ libreoffice-qt6 ];
  })
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [ libreoffice-bin ];
  })
];
```
**Always use `lib.mkMerge`**, never `//` for conditional merging.

### 5. Collector Aspect
**When:** Multiple features contribute config to a single collector target.
```nix
# Base (syncthing.nix)
flake.modules.nixos.syncthing = {
  services.syncthing.enable = true;
};

# Contributor (homeserver.nix)
flake.modules.nixos.syncthing = {
  services.syncthing.settings.devices.homeserver = {
    id = "VNV2XTI-...";
  };
};
```
Multiple files contribute to the same aspect name — they merge automatically.

### 6. Constants Aspect
**When:** Sharing constant values across features regardless of context.
```nix
flake.modules.generic.systemConstants = { lib, ... }: {
  options.systemConstants = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };
  config.systemConstants = {
    adminEmail = "admin@test.org";
  };
};
```

### 7. DRY Aspect
**When:** Reusable configuration blocks following "Don't Repeat Yourself."
```nix
# Define reusable network config
flake.modules.networkInterface.subnet-A = {
  ipv6.routes = [{ address = "2001:..."; prefixLength = 64; }];
};

# Use via mkMerge
networking.interfaces."enp86s0" =
  with self.modules.networkInterface;
  lib.mkMerge [ subnet-A subnet-B { /* extra */ } ];
```

### 8. Factory Aspect
**When:** Generating parameterized features as templates producing multiple instances.
```nix
config.flake.factory.user = username: isAdmin: {
  nixos."${username}" = {
    users.users."${username}".name = username;
    extraGroups = lib.optionals isAdmin [ "wheel" ];
  };
};

# Usage:
flake.modules = lib.mkMerge [
  (self.factory.user "bob" true)
  (self.factory.user "alice" false)
];
```

### Pattern Selection
1. Define requirements compared to existing features
2. Assess alignment with available patterns
3. Implement — multiple patterns often apply simultaneously

---

## Comprehensive Example Structure

```
flake.nix
└── modules/
    ├── factory/         # Template generators (user factories, mount factories)
    ├── hosts/           # Host-specific aspects (inheriting from system types)
    ├── nix/             # Nix tool configs
    ├── programs/        # Application features
    ├── services/        # Service features
    ├── system/          # System type hierarchy (default→essential→basic→CLI→desktop)
    └── users/           # User features
```

System type hierarchy enables inheritance:
```
system-default → system-essential → system-basic → system-cli → system-desktop
```

Each layer adds capabilities, and hosts inherit from the appropriate level.

---

## Integration with Key Libraries

### flake-parts
The underlying flake module system. Provides `flake.modules` for storing module building blocks organized by class. Entry point:
```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
  (inputs.import-tree ./modules);
```

### den (vic/den)
Takes the dendritic pattern further with:
- `den.hosts`/`den.homes` — schema-driven host/user declarations
- `den.aspects` — aspect composition with `includes`/`provides`
- `den.provides` (batteries) — pre-built common patterns
- Context pipeline — automated config flow from schema to outputs
- Parametric dispatch — functions auto-activate based on context shape

**Den vs raw flake-parts:** Den adds the context pipeline and batteries on top. Raw flake-parts requires manual wiring of aspects to hosts. Den automates this via schema declarations.

### import-tree (vic/import-tree)
Auto-discovers all `.nix` files in a directory recursively. Files prefixed with `_` are excluded. Eliminates manual import lists.

### flake-file (vic/flake-file)
Each module declares its own flake inputs inline:
```nix
flake-file.inputs.catppuccin = {
  url = "github:catppuccin/nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```
Run `just write-flake` to regenerate `flake.nix` from all declarations.

---

## How Our Config Uses These Patterns

### Collector Pattern
Multiple files contribute to `den.aspects.catppuccin`, `den.aspects.fish`, etc.

### Simple Aspect
Most features (fish, catppuccin, git) define `homeManager` and/or `nixos` blocks.

### Multi Context via den
Den handles HM integration automatically via `home-manager.enable = true` on hosts — no manual `sharedModules` wiring needed.

### Feature-First Organization
```
modules/
  dendritic.nix          # Core infrastructure
  hosts.nix              # Host declarations
  deus.nix               # User aspect
  catppuccin.nix         # Theme feature
  fish.nix               # Shell feature
  hyprland/              # Compositor feature (split across files)
  nvim/                  # Editor feature
  ...
```

### Batteries Usage
```nix
den.aspects.deus = {
  includes = [
    den._.primary-user           # Built-in battery
    (den._.user-shell "fish")    # Parametric battery
  ];
};
```

---

## FAQ Highlights

**Q: Is this just a buzzword?**
A: No — "feature" carries specific meaning. The pattern requires abstraction layers within modules beyond standard organization, creating genuinely novel design concepts.

**Q: Should beginners start with this?**
A: Start simple; revisit when complexity increases. Experienced users benefit from adopting early.

**Q: Must I learn all 8 aspect patterns?**
A: No — they're optional inspiration. Simple and Collector patterns cover most use cases.

**Q: Why is `flake.nix` so empty?**
A: Dendritic design moves logic into modules, leaving `flake.nix` focused on inputs and structure.

**Q: How does it compare to templates/tools?**
A: It's a design methodology, not a template. It renders many templates obsolete by enabling users to create similar structures through simple principles.

---

## Reference Repositories

- [vic/vix](https://github.com/vic/vix) — Vic's personal config
- [drupol/infra](https://github.com/drupol/infra) — Infrastructure config
- [mightyiam/infra](https://github.com/mightyiam/infra) — Original pattern author's config

## Additional Resources

- [Vimjoyer: "Elevate Your Nix Config With Dendritic Pattern"](https://youtube.com) — Video tutorial
- [Vimjoyer: "Break Your Flake Into Parts"](https://youtube.com) — Flake Parts tutorial
- ["Flipping the Configuration Matrix"](https://not-a-ta.sk/flipping-the-configuration-matrix/) — Blog post by Pol Dellaiera
- GitHub search: `lang:nix flake.modules SOME-OPTION` to find implementations
