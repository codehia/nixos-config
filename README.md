# NixOS Configuration

Multi-machine NixOS flake configuration using the **dendritic pattern** — a feature-centric alternative to traditional host-centric NixOS configs. Currently manages:

| Host | Arch | Desktop | Description |
|---|---|---|---|
| `thinkpad` | x86\_64-linux | SwayFX + DMS | ThinkPad laptop |
| `personal` | x86\_64-linux | SwayFX + DMS | Personal desktop |

- **User**: deus (Soumya)
- **Theme**: Catppuccin Mocha (system-wide via catppuccin + stylix)
- **Editor**: Neovim (via nixCats)

## Commands

All commands are run via [just](https://github.com/casey/just):

| Command | Description |
|---|---|
| `just install` | Apply config: `nixos-rebuild switch --flake . --use-remote-sudo` |
| `just debug` | Apply with `--show-trace --verbose` |
| `just up` | Update all flake inputs |
| `just upp i=<name>` | Update a single flake input (e.g. `just upp i=home-manager`) |
| `just history` | Show NixOS generation history |
| `just clean` | Wipe generations older than 7 days |
| `just gc` | Garbage collect unused Nix store entries |
| `just write-flake` | Regenerate `flake.nix` from `flake-file` declarations |

## Installation

Fresh installs use [`disko-install`](https://github.com/nix-community/disko) which handles partitioning and NixOS installation in a single step.

### 1. Boot the NixOS installer ISO

Boot the target machine from a [NixOS installer ISO](https://nixos.org/download). An internet connection is required.

### 2. Run the install script

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/codehia/nixos-config/master/install.sh)
```

Or download first:

```bash
curl -fsSL https://raw.githubusercontent.com/codehia/nixos-config/master/install.sh -o install.sh
bash install.sh
```

The script will:
1. Ask which host to install (`thinkpad` or `personal`)
2. Show available block devices and ask for disk device path(s)
3. Print a summary and ask for confirmation before touching anything
4. Run `disko-install` — partitions disks and installs NixOS from the flake

**Disk layout by host:**

| Host | Disk | Layout |
|---|---|---|
| `thinkpad` | `main` (1 disk) | ESP + LUKS → Btrfs (`/`, `/home`, `/nix`, `/var/log`) |
| `personal` | `main` (fast) | ESP + LUKS → Btrfs (`/`, `/home`, `/nix`, `/var/log`) |
| `personal` | `slow` (archive) | LUKS → Btrfs (`/var/lib/btrbk`) |

Both hosts use `zramSwap` instead of a disk swap partition.

### 3. Set up secrets (sops-nix)

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix) using an age key tied to each machine. Before rebooting:

```bash
# Generate a new age key for this machine
mkdir -p /mnt/home/deus/.config/sops/age
age-keygen -o /mnt/home/deus/.config/sops/age/keys.txt

# Print the public key — you'll need it for the next step
cat /mnt/home/deus/.config/sops/age/keys.txt
```

Then, from the repo on another machine, add the new public key to `.sops.yaml` and re-encrypt any secrets that should be accessible on the new host:

```bash
# In the repo
sops updatekeys secrets/common.yaml
sops updatekeys secrets/<hostname>.yaml
```

### 4. Reboot

```bash
reboot
```

## Architecture

This config uses the **dendritic pattern** built on four pillars:

| Component | Role |
|---|---|
| [den](https://github.com/vic/den) | Declarative host/user management. Provides `aspects`, `hosts`, `provides`, and `default` for composing NixOS + home-manager config. |
| [flake-file](https://github.com/vic/flake-file) | Lets individual modules declare their own flake inputs inline. Aggregated into `flake.nix` by `nix run ".#write-flake"`. |
| [import-tree](https://github.com/vic/import-tree) | Auto-discovers all `.nix` files under `modules/`. Files prefixed with `_` are excluded. |
| [flake-parts](https://github.com/hercules-ci/flake-parts) | Module system that ties everything together via `mkFlake`. |

### Bootstrap Flow

```
flake.nix
  └─ outputs = inputs: flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules)
       │
       ├─ import-tree discovers every .nix file in modules/ (except _-prefixed)
       ├─ Each file is a flake-parts module receiving { inputs, den, ... }
       ├─ den merges all aspects, hosts, defaults, and provides
       └─ Final output: NixOS system config for each declared host
```

The `flake.nix` is **auto-generated** — never edit it manually. Instead, declare inputs in individual modules via `flake-file.inputs` and run `just write-flake` to regenerate.

## Directory Structure

```
modules/
├── dendritic.nix           # Core infrastructure: den, flake-file, import-tree, flake-parts, nixpkgs
├── hosts.nix               # Host declarations (thinkpad + user deus)
├── default.nix             # Global defaults (stateVersion)
├── unstable-overlay.nix    # Overlay: pkgs.unstable.* from nixpkgs-unstable
├── unfree.nix              # Allowlisted unfree packages
├── home-manager.nix        # home-manager setup + den helpers
├── deus.nix                # User aspect: primary-user, shell, home settings
│
├── thinkpad/
│   ├── thinkpad.nix        # Host aspect: NixOS system config + includes all feature aspects
│   ├── _hardware-configuration.nix  # Hardware config (excluded from import-tree)
│   ├── _disko-config.nix   # Disk partitioning (excluded from import-tree)
│   └── kinesis.kbd         # Kanata keyboard layout
│
├── hyprland/
│   ├── hyprland.nix        # Compositor config + packages (collector pattern: other files merge in)
│   ├── binds.nix           # Keybindings (merges into hyprland aspect)
│   ├── hyprpaper.nix       # Wallpaper manager
│   ├── pyprland.nix        # Pyprland scratchpads
│   └── pyprland.toml       # Pyprland config
│
├── waybar/
│   ├── waybar.nix          # Status bar aspect
│   ├── waybar.json         # Bar layout
│   └── waybar.css          # Bar styles
│
├── nvim/
│   ├── nvim.nix            # Neovim aspect via nixCats (plugins in Nix)
│   ├── init.lua            # Neovim entry point
│   └── lua/                # Runtime Lua config (keymaps, plugins, LSP)
│
├── catppuccin.nix          # Catppuccin Mocha theme (system-wide)
├── stylix.nix              # Stylix base16 theming
├── fonts.nix               # Font configuration
├── fish.nix                # Fish shell config
├── ghostty.nix             # Ghostty terminal
├── kitty.nix               # Kitty terminal
├── tmux.nix                # Tmux config
├── rofi.nix                # Application launcher
├── git.nix                 # Git config
├── lazygit.nix             # Lazygit TUI
├── direnv.nix              # direnv for per-project shells
├── browser.nix             # Zen browser
├── secrets.nix             # sops-nix secrets management
├── packages.nix            # Additional system/user packages
├── services.nix            # User services (blueman, nm-applet, etc.)
├── programs.nix            # Misc programs (thunar, btop, etc.)
├── cursor.nix              # Cursor theme
├── disko.nix               # Disko flake input
└── apple-fonts.nix         # Apple fonts
```

## Module Layers

Configuration is organized in three layers:

### 1. Infrastructure (`dendritic.nix`, `hosts.nix`, `default.nix`, `unstable-overlay.nix`, `unfree.nix`, `home-manager.nix`)

Sets up the build system: flake inputs, host declarations, overlays, unfree allowlisting, home-manager integration. These are the plumbing.

### 2. User and Host (`deus.nix`, `thinkpad/thinkpad.nix`)

Define *who* and *what machine*. The user aspect sets identity and shell. The host aspect configures hardware, boot, networking, and — critically — **includes** all the feature aspects it wants.

### 3. Feature Aspects (everything else)

Self-contained features like `catppuccin.nix`, `hyprland/`, `nvim/`, etc. Each defines a `den.aspects.<name>` with `nixos` and/or `homeManager` config. They are inert until a host aspect includes them via `includes`.

## Aspect Patterns

### Simple aspect (home-manager only)

```nix
{ den, ... }: {
  den.aspects.direnv = {
    homeManager = { ... }: {
      programs.direnv.enable = true;
    };
  };
}
```

### Aspect with its own flake input

Modules can declare flake inputs inline via `flake-file.inputs`. These get aggregated into `flake.nix` when you run `just write-flake`.

```nix
{ inputs, ... }: {
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.catppuccin = {
    homeManager = { ... }: {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];
      catppuccin.enable = true;
    };
  };
}
```

### Aspect using unstable packages

No `specialArgs` needed — unstable packages are available everywhere via the overlay:

```nix
{ den, ... }: {
  den.aspects.example = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.unstable.some-package ];
    };
  };
}
```

### Collector pattern (multiple files, one aspect)

Several files can contribute to the same aspect and their attrs merge. This is how `hyprland/` works — `hyprland.nix` defines the base config while `binds.nix` adds keybindings to the same `den.aspects.hyprland`:

```nix
# hyprland/binds.nix — merges into the hyprland aspect defined in hyprland.nix
{ ... }: {
  den.aspects.hyprland = {
    homeManager = { ... }: {
      wayland.windowManager.hyprland.settings.bind = [ ... ];
    };
  };
}
```

### Aspect composition via `includes`

The host aspect pulls in features by listing them in `includes`:

```nix
{ den, ... }: {
  den.aspects.thinkpad = {
    nixos = { ... }: { /* system config */ };
    includes = [
      den.aspects.catppuccin
      den.aspects.hyprland
      den.aspects.nvim
      # ...
    ];
  };
}
```

## Adding a New Aspect

1. Create `modules/<name>.nix`:
   ```nix
   { den, ... }: {
     den.aspects.<name> = {
       homeManager = { pkgs, ... }: {
         # your config
       };
     };
   }
   ```
2. If it needs a flake input, add `flake-file.inputs.<input-name> = { ... };` and run `just write-flake`.
3. Add `den.aspects.<name>` to the `includes` list in the relevant host aspect (`modules/thinkpad/thinkpad.nix`, `modules/personal/personal.nix`, or both).
4. Apply: `just install`.

## Adding a New Host

1. Add the host declaration in `modules/hosts.nix`:
   ```nix
   den.hosts.x86_64-linux.<hostname>.users.deus = {};
   ```
2. Create `modules/<hostname>/<hostname>.nix` with a `den.aspects.<hostname>` containing the hardware config and `includes` list.
3. Prefix hardware-specific files with `_` so import-tree ignores them (import them explicitly in the host aspect).
4. Apply: `just install`.

## Key Conventions

- **`_` prefix** — Files starting with `_` are ignored by import-tree. Use for hardware configs and disko configs that need explicit imports.
- **`den._` shorthand** — `den._` is an alias for `den.provides` (e.g. `den._.unfree`, `den._.primary-user`, `den._.home-manager`).
- **No `specialArgs`** — Unstable packages via `pkgs.unstable.*` overlay; flake inputs via flake-parts module args (`{ inputs, ... }`).
- **Never edit `flake.nix`** — It's auto-generated. Declare inputs in modules and run `just write-flake`.
- **`den.default`** — Config applied to all hosts/users (overlays, stateVersion, etc.).
- **`den.base.conf`** — Applied to the flake-parts `perSystem` level (e.g. for overlays in devShells).

## Neovim

Uses [nixCats](https://github.com/BirdeeHub/nixCats-nvim) — plugins and LSP servers are managed in Nix (`modules/nvim/nvim.nix`) while runtime config is standard Lua (`modules/nvim/lua/`). The built package is aliased to both `vim` and `nvim`.

## Dev Environment

A `devenv.nix` configures:
- **alejandra** — Nix formatter (pre-commit hook)
- **lua-ls** — Lua language server + linter (pre-commit hook)
- **Nix LSP** — Language support for `.nix` files
