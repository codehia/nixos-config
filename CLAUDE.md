# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Multi-machine NixOS flake configuration for user `deus` (Soumya) using the **dendritic pattern** via `den` (vic/den) and `flake-file` (vic/flake-file). Currently manages the `thinkpad` host (x86_64-linux) with Hyprland (Wayland compositor), home-manager, and catppuccin theming. Additional hosts can be added as den host declarations.

## Commands

```bash
just install       # Apply config: nixos-rebuild switch --flake . --sudo
just debug         # Apply with --show-trace --verbose
just up            # Update all flake inputs
just upp i=<name>  # Update a single flake input (e.g., just upp i=home-manager)
just clean         # Wipe generations older than 7 days
just gc            # Garbage collect unused store entries
just write-flake   # Regenerate flake.nix from flake-file declarations
```

## Architecture

**Dendritic pattern**: Feature-centric aspects instead of host-centric organization. Uses `den` for declarative host/user management, `flake-file` for auto-generating `flake.nix`, `import-tree` for auto-discovering all modules, and `flake-parts` as the module system.

**Flake inputs**: Declared in individual modules via `flake-file.inputs`. nixpkgs 25.11 (stable) + nixpkgs-unstable. Unstable packages accessed via overlay as `pkgs.unstable.*` (no specialArgs).

**Module structure** (`modules/`):
- `dendritic.nix` — Core infrastructure (den, flake-file, import-tree, flake-parts, systems)
- `hosts.nix` — Host declarations (`den.hosts.x86_64-linux.thinkpad.users.deus`)
- `unstable-overlay.nix` — Overlay providing `pkgs.unstable` namespace
- `unfree.nix` — Unfree packages allowlist via `den.provides.unfree`
- `deus.nix` — User aspect (primary-user, shell, home settings)
- `thinkpad/thinkpad.nix` — Host aspect (NixOS system config, includes all feature aspects)
- `thinkpad/_hardware-configuration.nix` — Hardware (underscore = ignored by import-tree)
- `thinkpad/_disko-config.nix` — Disk layout
- Feature aspects: `catppuccin.nix`, `stylix.nix`, `fonts.nix`, `fish.nix`, `ghostty.nix`, `kitty.nix`, `tmux.nix`, `rofi.nix`, `git.nix`, `lazygit.nix`, `direnv.nix`, `browser.nix`, `secrets.nix`, `packages.nix`, `services.nix`, `programs.nix`, `cursor.nix`
- `hyprland/` — Compositor config split into `hyprland.nix`, `binds.nix`, `hyprpaper.nix`, `pyprland.nix`
- `waybar/` — Status bar with `waybar.nix`, `waybar.json`, `waybar.css`
- `nvim/` — Neovim via nixCats with `nvim.nix` and `lua/` config

**Neovim**: Uses `nixCats` framework — plugins/LSPs are managed in Nix (`nvim/nvim.nix`) while runtime config is standard Lua (`nvim/lua/`). The package is aliased to `vim`/`nvim`. LSP categories: lua, nix, python, typescript, go (disabled).

## Dev Environment

A `devenv.nix` configures pre-commit hooks: `nixfmt` (Nix formatting), `stylua` (Lua formatting), `shellcheck` (shell linting).

## Branch Strategy

- `master` is the main branch
- `personal` branch carries machine-specific personal changes

## Key Patterns

- **No specialArgs/extraSpecialArgs** — unstable packages via overlay (`pkgs.unstable.*`), inputs via flake-parts module args
- **Feature-centric aspects** — each feature (catppuccin, hyprland, nvim, etc.) is a self-contained `den.aspects.<name>` with its own `flake-file.inputs` where needed
- **Collector pattern** — multiple files can contribute to the same aspect (e.g., hyprland binds merge into hyprland aspect)
- **import-tree** auto-discovers all `.nix` files in `modules/` (files prefixed with `_` are excluded)
- Secrets management via sops-nix (age-based encryption)
- Disk partitioning declared via disko
- Catppuccin Mocha theme applied system-wide through the catppuccin module
