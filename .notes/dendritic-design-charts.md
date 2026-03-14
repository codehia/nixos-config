# Dendritic Design Pattern — Visual Guide

---

## 1. Traditional vs Dendritic: The Core Shift

```
   ═══ TRADITIONAL (Host-Centric) ═══        ═══ DENDRITIC (Feature-Centric) ═══

   hosts/                                     modules/
   ├── laptop/                                ├── fish.nix ─────────┐
   │   ├── config.nix ◄── fish config         │   nixos: ...        │ ONE file
   │   │                   git config          │   homeManager: ...  │ ALL hosts
   │   │                   hyprland config     │   darwin: ...       │
   │   │                   packages...         ├── git.nix ──────────┤
   │   └── hardware.nix                       │   homeManager: ...  │
   ├── server/                                ├── hyprland/ ────────┤
   │   ├── config.nix ◄── fish config AGAIN   │   hyprland.nix      │
   │   │                   git config AGAIN    │   binds.nix         │
   │   │                   nginx config        ├── hosts.nix ────────┘
   │   └── hardware.nix                       │   declares: laptop, server
   └── mac/                                   └── default.nix
       └── config.nix ◄── fish config AGAIN        global defaults
                           git config AGAIN


   Problem: Feature scattered         Solution: Feature consolidated
            across host files                    in one place

   Add bluetooth:                     Add bluetooth:
     edit laptop/config.nix             create bluetooth.nix ← DONE
     edit server/config.nix
     handle conditionals...
```

---

## 2. The Dendritic Rule

```
   ┌─────────────────────────────────────────────────────────────────┐
   │                                                                 │
   │   EVERY .nix file (except flake.nix/default.nix)               │
   │   is a MODULE of the TOP-LEVEL configuration                   │
   │                                                                 │
   │   Each module:                                                  │
   │     1. Implements ONE feature                                   │
   │     2. Applies to ALL relevant targets                          │
   │     3. Lives at a path that NAMES the feature                   │
   │                                                                 │
   └─────────────────────────────────────────────────────────────────┘

   modules/
   ├── fish.nix          ◄── feature: fish shell
   ├── catppuccin.nix    ◄── feature: catppuccin theme
   ├── git.nix           ◄── feature: git configuration
   ├── hyprland/         ◄── feature: hyprland compositor
   │   ├── hyprland.nix       (split across files = collector pattern)
   │   └── binds.nix
   └── _hardware.nix     ◄── underscore = excluded from auto-import
```

---

## 3. Features vs Aspects vs Classes

```
   ┌─────────── FEATURE (fish.nix) ─────────────────────────┐
   │                                                         │
   │  A feature is a top-level module containing             │
   │  one or more ASPECTS for different CLASSES:             │
   │                                                         │
   │  ┌─────────────────┐  ┌─────────────────┐              │
   │  │  ASPECT: nixos   │  │ ASPECT: homeMgr │              │
   │  │  CLASS: nixos     │  │ CLASS: homeMgr  │              │
   │  │                  │  │                  │              │
   │  │  programs.fish   │  │  programs.fish   │              │
   │  │    .enable=true  │  │    .shellAliases │              │
   │  │                  │  │    .plugins      │              │
   │  └─────────────────┘  └─────────────────┘              │
   │                                                         │
   │  ┌─────────────────┐                                    │
   │  │ ASPECT: darwin   │  (optional, for macOS)            │
   │  │ CLASS: darwin    │                                    │
   │  │  programs.fish   │                                    │
   │  │    .enable=true  │                                    │
   │  └─────────────────┘                                    │
   │                                                         │
   └─────────────────────────────────────────────────────────┘


   CLASSES define configuration domains:
   ┌────────────────┬─────────────────────────────────────┐
   │ nixos          │ NixOS system configuration          │
   │ darwin         │ macOS/nix-darwin configuration      │
   │ homeManager    │ Home Manager user environment       │
   │ generic        │ Cross-context compatible            │
   │ <custom>       │ User-defined via den.provides.fwd   │
   └────────────────┴─────────────────────────────────────┘
```

---

## 4. The Eight Aspect Design Patterns

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  1. SIMPLE            One feature, multiple contexts, no deps       │
│     ┌──────┐                                                        │
│     │ feat │──► nixos block                                         │
│     │      │──► homeManager block                                   │
│     │      │──► darwin block                                        │
│     └──────┘                                                        │
│                                                                     │
│  2. MULTI CONTEXT     Feature needs config in parent + child        │
│     ┌──────┐     sharedModules                                      │
│     │ feat │──► nixos ────────────► homeManager (private)            │
│     └──────┘                                                        │
│                                                                     │
│  3. INHERITANCE       Extend/compose existing features              │
│     ┌──────┐     imports                                            │
│     │ desk │──► [ cli, mail, browser, kde ]                         │
│     └──────┘     ▲ parent features                                  │
│                                                                     │
│  4. CONDITIONAL       Platform/condition-dependent config           │
│     ┌──────┐     mkMerge                                            │
│     │ feat │──► [ base, mkIf isLinux {...}, mkIf isDarwin {...} ]   │
│     └──────┘     (always use mkMerge, never //)                     │
│                                                                     │
│  5. COLLECTOR         Multiple files contribute to one target       │
│     ┌────┐ ┌────┐ ┌────┐                                           │
│     │ A  │ │ B  │ │ C  │ ──► all write to aspects.syncthing        │
│     └────┘ └────┘ └────┘     (auto-merged by module system)         │
│                                                                     │
│  6. CONSTANTS         Shared values across all features             │
│     ┌──────┐                                                        │
│     │const │──► generic class with mkOption                         │
│     └──────┘   config.systemConstants.adminEmail = "..."            │
│                                                                     │
│  7. DRY               Reusable config blocks                        │
│     ┌──────┐                                                        │
│     │subnet│──► custom class, used via mkMerge [ A, B, extra ]     │
│     └──────┘                                                        │
│                                                                     │
│  8. FACTORY           Parameterized templates                       │
│     ┌──────┐                                                        │
│     │ fn   │──► factory.user "bob" true → nixos.bob + darwin.bob   │
│     └──────┘   generates multiple aspects from parameters           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘


   MOST COMMON in practice:
   ├── Simple ────── 80% of features (fish, git, catppuccin)
   ├── Collector ─── split features (hyprland/, nvim/)
   └── Conditional ─ platform-specific packages
```

---

## 5. System Type Hierarchy (Inheritance Pattern)

```
   ┌─────────────────┐
   │  system-default  │  stateVersion, nix settings, locale
   └────────┬────────┘
            │ imports
   ┌────────▼────────┐
   │ system-essential │  base packages, SSH, firewall
   └────────┬────────┘
            │ imports
   ┌────────▼────────┐
   │  system-basic    │  networking, time, users
   └────────┬────────┘
            │ imports
   ┌────────▼────────┐
   │   system-cli     │  dev tools, git, tmux, fish
   └────────┬────────┘
            │ imports
   ┌────────▼────────┐
   │  system-desktop  │  GUI, hyprland, fonts, audio
   └─────────────────┘

   Hosts pick their level:
     server ──► imports system-cli
     laptop ──► imports system-desktop (gets everything above too)
```

---

## 6. Collector Pattern in Detail

```
   ┌─ hyprland/hyprland.nix ──────────────────────┐
   │  den.aspects.hyprland = {                     │
   │    homeManager = {                            │
   │      wayland.windowManager.hyprland = {       │
   │        enable = true;                         │──┐
   │        settings.general = { ... };            │  │
   │      };                                       │  │
   │    };                                         │  │
   │  };                                           │  │
   └──────────────────────────────────────────────┘  │
                                                      │ MODULE SYSTEM
   ┌─ hyprland/binds.nix ────────────────────────┐   │ AUTO-MERGES
   │  den.aspects.hyprland = {                    │   │ all contributions
   │    homeManager = {                           │   │ to same aspect
   │      wayland.windowManager.hyprland = {      │──┘
   │        settings.bind = [ ... ];              │
   │      };                                      │
   │    };                                        │
   │  };                                          │        ▼
   └──────────────────────────────────────────────┘
                                              den.aspects.hyprland
   ┌─ hyprland/hyprpaper.nix ───────────────┐     (merged result)
   │  den.aspects.hyprland = {               │         │
   │    homeManager = {                      │─────────┘
   │      services.hyprpaper = { ... };      │
   │    };                                   │
   │  };                                     │
   └─────────────────────────────────────────┘
```

---

## 7. How Features Compose into Hosts

```
   ┌── hosts.nix ──────────────────────────────────────────────┐
   │  den.hosts.x86_64-linux.thinkpad = {                      │
   │    home-manager.enable = true;                            │
   │    users.deus = {};                                       │
   │  };                                                       │
   └──────────────────────────┬────────────────────────────────┘
                              │
              import-tree loads ALL modules/*.nix
                              │
                              ▼
   ┌──────────────────────────────────────────────────────────────┐
   │                    ASPECT COMPOSITION                        │
   │                                                              │
   │   Aspects named after host/user auto-attach:                 │
   │                                                              │
   │   den.aspects.thinkpad ──► attaches to thinkpad host         │
   │   den.aspects.deus ──────► attaches to deus user             │
   │                                                              │
   │   Aspects with includes chain in dependencies:               │
   │                                                              │
   │   deus ──includes──► primary-user                            │
   │        ──includes──► user-shell "fish"                       │
   │                                                              │
   │   All other aspects (catppuccin, fish, git, hyprland...)     │
   │   apply to ALL hosts/users (no conditional logic needed)     │
   │                                                              │
   └──────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
                    den context pipeline
                    resolves + deduplicates
                              │
                              ▼
              ┌───────────────────────────────┐
              │  nixosConfigurations.thinkpad  │
              │  homeConfigurations            │
              │    ."deus@thinkpad"            │
              └───────────────────────────────┘
```

---

## 8. Raw flake-parts vs Den

```
   ═══ RAW FLAKE-PARTS ═══                ═══ WITH DEN ═══

   You manually wire aspects              Den auto-wires via schema
   to hosts in flake boilerplate:         declarations:

   flake.nixosConfigurations =            den.hosts.x86_64-linux
     mkNixos "x86_64-linux"                .thinkpad.users.deus = {};
       "laptop";
                                          den.aspects.fish = {
   flake.modules.nixos.laptop = {           homeManager = { ... };
     imports = [                          };
       self.modules.nixos.fish
       self.modules.nixos.git             # That's it. Den handles:
       ...                                #  - wiring aspects to hosts
     ];                                   #  - HM integration
   };                                     #  - output generation
                                          #  - deduplication
   flake.modules.nixos.fish = {           #  - context pipeline
     programs.fish.enable = true;
   };

   MORE MANUAL                            MORE AUTOMATIC
   More explicit control                  Less boilerplate
   No context pipeline                    Context-driven dispatch
   No parametric functions                Parametric functions
   No batteries                           Built-in batteries
```

---

## 9. File Organization Decision Tree

```
   Starting a new feature?
   │
   ├── Single file sufficient?
   │   │
   │   ├── YES ──► modules/feature-name.nix
   │   │           (Simple Aspect)
   │   │
   │   └── NO ───► modules/feature-name/
   │               ├── feature-name.nix   (main config)
   │               ├── binds.nix          (sub-concern)
   │               └── styles.css         (data file)
   │               (Collector Aspect — all contribute to same den.aspects.X)
   │
   ├── Needs its own flake input?
   │   └── YES ──► Add flake-file.inputs.X in the feature file
   │               (run `just write-flake` after)
   │
   ├── Platform-specific behavior?
   │   └── YES ──► Use lib.mkMerge + mkIf inside the aspect
   │               (Conditional Aspect)
   │
   ├── Depends on other features?
   │   └── YES ──► includes = [ other-aspect ]
   │               (Inheritance Aspect)
   │
   └── Generates multiple similar configs?
       └── YES ──► Factory function
                   (Factory Aspect)
```

---

## 10. Import Rules

```
   ╔══════════════════════════════════════════════════════════════╗
   ║                    IMPORT RULES                              ║
   ║                                                              ║
   ║  ✓ DO: Import matching classes                               ║
   ║    nixos module ──imports──► nixos module                    ║
   ║    homeManager  ──imports──► homeManager module              ║
   ║                                                              ║
   ║  ✓ DO: Use generic for cross-context                         ║
   ║    generic module ──imports──► works in any class            ║
   ║                                                              ║
   ║  ✗ DON'T: Import across classes                              ║
   ║    nixos module ──imports──► homeManager module  ← WRONG     ║
   ║                                                              ║
   ║  ✗ DON'T: Conditional imports                                ║
   ║    mkIf condition [ import ./foo.nix ]           ← WRONG     ║
   ║    (content can be conditional; imports cannot)              ║
   ║                                                              ║
   ║  ✗ DON'T: Same import at multiple hierarchy levels           ║
   ║    parent imports foo, child also imports foo    ← WRONG     ║
   ║    (causes duplicate module errors)                          ║
   ║                                                              ║
   ║  ✓ DO: Use mkMerge for conditional content                   ║
   ║    lib.mkMerge [ base (mkIf cond extra) ]       ← CORRECT   ║
   ╚══════════════════════════════════════════════════════════════╝
```
