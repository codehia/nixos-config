# Architecture

The whole thing is built around **aspects** — each aspect is a `.nix` file that owns one
feature. Hosts and users list which aspects they want in their `includes`. That's it.

```
fish.nix   git.nix   catppuccin.nix   nvim/   hyprland/   rclone.nix   ...
                                ↓
  personal: includes fish, git, catppuccin, nvim, swayfx, rclone, ...
  thinkpad: includes the same + hyprland in extraAspects
  workstation: soumya gets fish, git, catppuccin, nvim, hyprland, ...
```

The framework that wires this together is [den](https://github.com/vic/den). It runs a pipeline:

1. Each host gets a context → the host aspect applies (all `nixos.*` config goes here)
2. Each user declared on that host gets their own context → the user aspect applies
3. All `homeManager.*` config from any included aspect flows to that user's home-manager
4. `nixos.*` config from user aspects also flows up to the system (via `mutual-provider`)

**Auto-discovery:** All `.nix` files under `modules/` are picked up automatically via git
(using `import-tree`). Files or folders prefixed with `_` are excluded. After creating a
new `.nix` file, `git add` it before building — otherwise the build won't see it.

**`flake.nix` is auto-generated.** Each module declares its own flake inputs with
`flake-file.inputs`. After adding or removing any of those, run `just write-flake`.

---

## Folder structure

```
nixos-config/
├── flake.nix               # auto-generated, never edit by hand
├── Justfile                # all the just commands
├── .sops.yaml              # which age keys can decrypt which secrets files
│
├── secrets/                # sops-encrypted files
│   ├── deus.yaml           # deus's SSH private key + password (all hosts)
│   ├── soumya.yaml         # soumya's SSH private key + password
│   ├── rclone.yaml         # rclone.conf (personal + thinkpad only)
│   └── common.yaml         # shared secrets (GitHub token, etc.)
│
├── assets/.wallpapers/     # synced to ~/Pictures/Wallpapers on activation
├── notes/                  # reference docs
│
└── modules/
    ├── den.nix             # bootstraps den + flake-file + import-tree
    ├── defaults.nix        # applied to every host and user
    ├── schema.nix          # unstable overlay, activates home-manager globally
    │
    ├── hosts/
    │   ├── personal/default.nix       # host declaration + personal aspect
    │   ├── thinkpad/default.nix       # host declaration + thinkpad aspect
    │   └── workstation/default.nix
    │
    ├── users/
    │   ├── deus.nix        # deus's feature includes, WM selector, identity
    │   └── soumya.nix      # soumya's feature includes, identity
    │
    └── aspects/
        ├── appearance.nix  # stylix + catppuccin theming (combined)
        ├── browser.nix     # zen browser
        ├── packages.nix    # misc user packages
        ├── tui.nix         # TUI tools
        ├── cli-utils.nix   # CLI utilities
        ├── rclone.nix      # rclone gdrive mount
        ├── ssh.nix         # SSH key deployment via sops
        ├── secrets.nix     # sops secrets config
        ├── mullvad.nix     # Mullvad VPN
        ├── lact.nix        # GPU fan control
        ├── tailscale.nix   # Tailscale VPN
        ├── avahi.nix       # mDNS
        ├── bluetooth.nix   # Bluetooth
        ├── tlp.nix         # laptop power management
        ├── work.nix        # work-specific tools (soumya)
        ├── apps/           # graphical app bundles (chat, media, creative...)
        ├── shell-tools/    # shell utilities (bat, eza, fzf, yazi, zoxide...)
        ├── terminal/       # terminal emulators + shell (ghostty, kitty, fish, tmux)
        ├── vcs/            # version control (git, lazygit, direnv)
        ├── editor/         # editors — nvim + vscode bundle
        ├── nvim/           # Neovim config (collector pattern across multiple files)
        ├── hyprland/       # Hyprland WM config
        ├── swayfx/         # SwayFX WM config
        ├── niri/           # Niri WM
        ├── kanata/         # keyboard remapping
        ├── waybar/         # Waybar status bar
        ├── wayland/        # Wayland compositor utilities
        ├── dms/            # DankMaterialShell (desktop shell)
        └── system/         # system-level aspects (greetd, networking, boot, ...)
```
