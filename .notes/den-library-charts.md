# Den Library & Framework — Visual Guide

---

## 1. Den: Library vs Framework

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEN                                         │
│                                                                     │
│  ┌──────────────────────┐     ┌──────────────────────────────────┐  │
│  │   LIBRARY (den.lib)  │     │     FRAMEWORK                    │  │
│  │                      │     │                                  │  │
│  │  Domain-agnostic     │     │  den.hosts    den.homes          │  │
│  │  Works with ANY Nix  │     │  den.aspects  den.default        │  │
│  │  config class        │     │  den.ctx      den.provides       │  │
│  │                      │     │                                  │  │
│  │  - parametric        │     │  Pre-wired for:                  │  │
│  │  - canTake / take    │────►│  - NixOS                         │  │
│  │  - statics / owned   │     │  - nix-Darwin                    │  │
│  │  - ctxApply          │     │  - Home Manager                  │  │
│  │                      │     │  - Custom classes                │  │
│  │  Use for: Terranix,  │     │                                  │  │
│  │  NixVim, custom...   │     │  Use for: OS configs             │  │
│  └──────────────────────┘     └──────────────────────────────────┘  │
│        foundation                    built on top                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Architecture Stack

```
╔═══════════════════════════════════════════════════════════╗
║                    YOUR CONFIG                            ║
║   modules/fish.nix  modules/catppuccin.nix  modules/...   ║
╠═══════════════════════════════════════════════════════════╣
║                 INTEGRATION LAYER                         ║
║   Home Manager  │  Hjem  │  nix-maid  │  Custom classes   ║
║   (den.provides.forward routes between classes)           ║
╠═══════════════════════════════════════════════════════════╣
║              DEN FRAMEWORK API                            ║
║                                                           ║
║   den.hosts ──── declares what exists                     ║
║   den.aspects ── defines behavior per class               ║
║   den.ctx ────── manages data flow                        ║
║   den.provides ─ reusable batteries                       ║
║   den.default ── global defaults                          ║
╠═══════════════════════════════════════════════════════════╣
║              DEN CORE LIBRARY                             ║
║                                                           ║
║   parametric  canTake  take  ctxApply  statics  owned     ║
╠═══════════════════════════════════════════════════════════╣
║              FOUNDATION                                   ║
║                                                           ║
║   flake-aspects ─── aspect primitives                     ║
║   nixpkgs ───────── packages + lib                        ║
║   flake-parts ───── flake module system                   ║
║   import-tree ───── auto-discovery                        ║
║   flake-file ────── inline input declarations             ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 3. Context Pipeline (How Config Flows)

```
 den.hosts.x86_64-linux.thinkpad
 │  users.deus = {}
 │  home-manager.enable = true
 │
 ▼
┌──────────────────────────────────────────────────────────────┐
│  STAGE 1: Host Context                                       │
│                                                              │
│  context = { host }                                          │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │ fixedTo { host }                                    │     │
│  │  → owned configs (aspects named after this host)    │     │
│  │  → statics (unconditional includes)                 │     │
│  │  → parametric matches (functions wanting { host })  │     │
│  └─────────────────────────────────────────────────────┘     │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  STAGE 2: User Context (for each user)                       │
│                                                              │
│  context = { host, user }                                    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │ fixedTo { host, user }                              │     │
│  │  → owned configs (aspects named after this user)    │     │
│  │  → parametric matches (functions wanting both)      │     │
│  └─────────────────────────────────────────────────────┘     │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  STAGE 3: Derived Contexts (from batteries)                  │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  hm-host     │  │  hm-user     │  │  wsl-host    │       │
│  │  { host }    │  │  {host,user} │  │  { host }    │       │
│  │              │  │              │  │              │       │
│  │  if HM       │  │  per HM      │  │  if WSL      │       │
│  │  enabled     │  │  user        │  │  enabled     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  STAGE 4: Deduplication                                      │
│                                                              │
│  1st occurrence ─► fixedTo (owned + statics + parametric)    │
│  2nd+ occurrence ► atLeast (parametric only)                 │
│                                                              │
│  Prevents duplicate module application                       │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  STAGE 5: Output Generation                                  │
│                                                              │
│  ┌────────────────────┐  ┌─────────────────────────────┐     │
│  │nixosConfigurations │  │homeConfigurations            │     │
│  │  .thinkpad         │  │  ."deus@thinkpad"            │     │
│  └────────────────────┘  └─────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Standalone Homes (Alternate Path)

```
 den.homes.x86_64-linux.myuser
 │
 ▼
┌────────────────────────────────┐
│  context = { home }            │  Bypasses host pipeline entirely
│                                │
│  fixedTo { home }              │  Functions wanting { host }
│  Only { home } functions run   │  stay INACTIVE
└────────────────┬───────────────┘
                 ▼
        homeConfigurations.myuser
```

---

## 5. Aspect Anatomy

```
den.aspects.catppuccin
│
├── nixos = { ... }: { ... }          ◄── NixOS system module
│     imports catppuccin.nixosModules
│
├── homeManager = { ... }: { ... }    ◄── Home Manager module
│     imports catppuccin.homeModules
│     catppuccin.flavor = "mocha"
│
├── darwin = { ... }: { ... }         ◄── (optional) macOS module
│
├── user = { ... }: { ... }           ◄── (optional) per-user config
│
├── includes = [                      ◄── Dependencies (DAG)
│     den._.primary-user
│     (den._.user-shell "fish")
│     other-aspect
│   ]
│
└── provides = { ... }                ◄── Reusable sub-aspects
```

---

## 6. Parametric Dispatch (Context-Driven Activation)

```
   Function signatures determine when they run:

   ┌─────────────────────────────┐
   │ ({ ... }: { ... })          │ ──► Runs ALWAYS (no context needed)
   └─────────────────────────────┘

   ┌─────────────────────────────┐
   │ ({ host, ... }: { ... })    │ ──► Runs only in HOST context
   └─────────────────────────────┘

   ┌─────────────────────────────┐
   │ ({host, user, ...}: { ... })│ ──► Runs only in HOST+USER context
   └─────────────────────────────┘

   ┌─────────────────────────────┐
   │ ({ home, ... }: { ... })    │ ──► Runs only in HOME context
   └─────────────────────────────┘


   Example in practice:

   den.aspects.myfeature = {
     includes = [
       ── always included ──────────────────────────
       some-static-aspect

       ── only when host+user context exists ───────
       ({ host, user, ... }: {
         homeManager.home.sessionVariables.HOST = host.name;
       })
     ];
   };

   NO mkIf NEEDED — the context shape IS the condition
```

---

## 7. Custom Classes via Forwarding

```
   ┌──────────────┐     den.provides.forward      ┌──────────────┐
   │  fromClass    │  ─────────────────────────►   │  intoClass   │
   │  "user"       │     routes config to          │  "nixos"     │
   │               │     intoPath:                 │              │
   │  user = {     │     users.users.<name>        │  users.users │
   │    extraGroups│                               │    .deus =   │
   │    shell      │                               │    { ... }   │
   │    ...        │                               │              │
   │  }            │                               │              │
   └──────────────┘                                └──────────────┘


   Built-in forwards:
   ┌──────────┐          ┌──────────────────────────────┐
   │ user     │ ────────►│ users.users.<name> on nixos   │
   │          │ ────────►│ users.users.<name> on darwin   │
   ├──────────┤          ├──────────────────────────────┤
   │ homeMgr  │ ────────►│ home-manager.users.<name>     │
   ├──────────┤          ├──────────────────────────────┤
   │ os       │ ────────►│ nixos AND darwin (both)        │
   └──────────┘          └──────────────────────────────┘
```

---

## 8. Batteries (den.provides / den._)

```
   ┌─────────────────────────────────────────────────────────────┐
   │  den._.primary-user          Marks user as primary          │
   │  den._.user-shell "fish"     Sets login shell (parametric)  │
   │  den._.hostname              Sets hostname from host name   │
   │  den._.define-user           Creates OS user accounts       │
   │  den.provides.forward        Custom class routing           │
   │  den.provides.unfree         Unfree package allowlist       │
   └─────────────────────────────────────────────────────────────┘

   Usage:
   den.aspects.deus = {
     includes = [
       den._.primary-user              ◄── static battery
       (den._.user-shell "fish")        ◄── parametric battery (note parens)
     ];
   };
```

---

## 9. Namespaces

```
   ┌─── Your Flake ───────────────────────────────────────────┐
   │                                                          │
   │  imports = [ (inputs.den.namespace "my" false) ];        │
   │                          ▲         ▲                     │
   │                          │         │                     │
   │                     name: "my"   local only              │
   │                                                          │
   │  my.vim = { homeManager.programs.vim.enable = true; };   │
   │  my.desktop = { includes = [ my.vim ]; nixos = ...; };   │
   │                                                          │
   │  den.aspects.laptop.includes = [ my.desktop ];           │
   │                                                          │
   └──────────────────────────────────────────────────────────┘

   ┌─── Exported Namespace ───────────────────────────────────┐
   │                                                          │
   │  imports = [ (inputs.den.namespace "shared" true) ];     │
   │                                              ▲           │
   │                                         exported!        │
   │                                                          │
   │  → Creates flake.denful.shared output                    │
   │  → Other flakes can import it:                           │
   │    (inputs.den.namespace "shared" [inputs.team-config])  │
   │                                                          │
   └──────────────────────────────────────────────────────────┘
```

---

## 10. Your Config's Data Flow

```
   ┌─ dendritic.nix ──────────────────────────────────────────┐
   │  imports den + flake-file flakeModules                   │
   │  declares all flake inputs                               │
   │  sets systems = ["x86_64-linux"]                         │
   └──────────────────────────┬───────────────────────────────┘
                              │
   ┌─ hosts.nix ──────────────▼───────────────────────────────┐
   │  den.hosts.x86_64-linux.thinkpad.users.deus = {}         │
   │  den.hosts.x86_64-linux.thinkpad.users.soumya = {}       │
   │  den.hosts.x86_64-linux.personal.users.deus = {}         │
   │  den.hosts.x86_64-linux.workstation.users.deus = {}      │
   └──────────────────────────┬───────────────────────────────┘
                              │ import-tree auto-loads all modules/
                              ▼
   ┌──────────────────────────────────────────────────────────┐
   │  ASPECTS (each file = one feature)                       │
   │                                                          │
   │  deus.nix ──────► den.aspects.deus                       │
   │                    includes: primary-user, user-shell     │
   │                    nixos: user account                    │
   │                    homeManager: home dir, session vars    │
   │                                                          │
   │  catppuccin.nix ► den.aspects.catppuccin                 │
   │                    nixos: import catppuccin nixosModule   │
   │                    homeManager: flavor=mocha, toggles     │
   │                                                          │
   │  fish.nix ──────► den.aspects.fish                       │
   │                    homeManager: plugins, aliases, init    │
   │                                                          │
   │  hyprland/*.nix ► den.aspects.hyprland (collector)       │
   │                    multiple files merge into one aspect   │
   │                                                          │
   │  default.nix ───► den.default                            │
   │                    nixos.system.stateVersion = "25.11"    │
   └──────────────────────────┬───────────────────────────────┘
                              │
                              ▼
                 nixosConfigurations.thinkpad
                 homeConfigurations."deus@thinkpad"
```
