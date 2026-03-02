# River Compositor Research

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [River-classic (0.3.x)](#river-classic-03x)
- [River 0.4+ (Modular)](#river-04-modular)
- [Migration Plan: Classic to 0.4+](#migration-plan-classic-to-04)
- [Window Managers for River 0.4+](#window-managers-for-river-04)
- [Layout Generators for River-classic](#layout-generators-for-river-classic)
- [Status Bars](#status-bars)
- [Ecosystem Tools](#ecosystem-tools)
- [Wayland Protocols](#wayland-protocols)
- [Configuration Reference (River-classic)](#configuration-reference-river-classic)
- [Tags System](#tags-system)
- [Scratchpad Patterns](#scratchpad-patterns)
- [NixOS Integration](#nixos-integration)

---

## Architecture Overview

River is a dynamic tiling Wayland compositor written in Zig, built on wlroots. Created by Isaac Freund in 2020, inspired by dwm and bspwm. Design philosophy: "Keeping things as simple as possible, reducing implicit state the user must keep in their head."

River runs well on hardware as old as a ThinkPad X200 (2008).

### The Split

As of 2025-2026, River exists as **two distinct projects**:

| | River-classic (0.3.x) | River 0.4+ |
|---|---|---|
| **Architecture** | Monolithic — compositor + WM in one binary | Modular — compositor and WM are separate processes |
| **Window management** | Built-in tag-based stack model | External WM via `river-window-management-v1` protocol |
| **Configuration** | `riverctl` commands in an init script | Compositor config via `riverctl`, WM config depends on chosen WM |
| **Layout** | External layout generators via `river-layout-v3` | Handled entirely by the external WM |
| **nixpkgs (25.11)** | `pkgs.river-classic`, module `programs.river-classic` | Not yet in stable nixpkgs |
| **Status** | Maintained as a stable fork, frozen at 0.3.x | Active development, the future of River |

---

## River-classic (0.3.x)

### Configuration Model

Configuration is an **executable file** at `$XDG_CONFIG_HOME/river/init` (typically `~/.config/river/init`). It runs as a process group leader after the Wayland server initializes but before the main loop. On exit, SIGTERM terminates this process group.

The init file is typically a POSIX shell script containing `riverctl` commands, but can be written in any language: Python, Lua, Zig, Perl, Nim, TypeScript, etc.

There is **no config reload mechanism**. To change settings, either run `riverctl` commands directly from a terminal or edit the init file (takes effect on next River start).

The `-c` flag overrides the default init path: `river -c "some shell command"`.

### Modes

Two built-in modes: `normal` and `locked`. The `locked` mode is special — keybindings in locked mode work even when the session is locked (useful for volume/brightness keys).

Custom modes can be declared:

```sh
riverctl declare-mode passthrough
riverctl map normal Super F11 enter-mode passthrough
riverctl map passthrough Super F11 enter-mode normal
```

### Complete riverctl Command Reference

#### Actions (Window/View Management)

```sh
riverctl close                                    # Close focused view
riverctl exit                                     # Shut down compositor
riverctl focus-view [-skip-floating] next|previous|up|down|left|right
riverctl focus-output next|previous|up|right|down|left|<name>
riverctl move up|down|left|right <delta>          # Move floating view by pixels
riverctl resize horizontal|vertical <delta>       # Resize view
riverctl snap up|down|left|right                  # Snap to screen edge
riverctl send-to-output [-current-tags] next|previous|up|right|down|left|<name>
riverctl spawn <shell_command>                    # Execute via /bin/sh -c
riverctl swap next|previous|up|down|left|right    # Swap view positions
riverctl toggle-float                             # Toggle floating
riverctl toggle-fullscreen                        # Toggle fullscreen
riverctl zoom                                     # Promote to top of stack
```

#### Tag Management

```sh
riverctl set-focused-tags <tags>                  # Show views matching bitfield
riverctl set-view-tags <tags>                     # Assign tags to focused view
riverctl toggle-focused-tags <tags>               # Toggle tag visibility
riverctl toggle-view-tags <tags>                  # Toggle view's tags
riverctl spawn-tagmask <tagmask>                  # Filter tags for new views
riverctl focus-previous-tags                      # Return to previous tags
riverctl send-to-previous-tags                    # Send view to previous tags
```

#### Layout Control

```sh
riverctl default-layout <namespace>               # Set default layout for all outputs
riverctl output-layout <namespace>                # Set layout for focused output
riverctl send-layout-cmd <namespace> <command>    # Send command to layout generator
```

#### Key/Mouse Mappings

```sh
riverctl declare-mode <name>                      # Create new mode
riverctl enter-mode <name>                        # Switch to mode
riverctl map [-release|-repeat|-layout <idx>] <mode> <modifiers> <key> <command>
riverctl map-pointer <mode> <modifiers> <button> <action|command>
riverctl map-switch <mode> lid|tablet <state> <command>
riverctl unmap [-release] <mode> <modifiers> <key>
riverctl unmap-pointer <mode> <modifiers> <button>
riverctl unmap-switch <mode> lid|tablet <state>
```

#### Window Rules

```sh
riverctl rule-add [-app-id <glob>|-title <glob>] float|no-float
riverctl rule-add [-app-id <glob>|-title <glob>] ssd|csd
riverctl rule-add [-app-id <glob>|-title <glob>] tags <tags>
riverctl rule-add [-app-id <glob>|-title <glob>] output <name>
riverctl rule-add [-app-id <glob>|-title <glob>] position <x> <y>
riverctl rule-add [-app-id <glob>|-title <glob>] dimensions <w> <h>
riverctl rule-add [-app-id <glob>|-title <glob>] fullscreen|no-fullscreen
riverctl rule-add [-app-id <glob>|-title <glob>] tearing|no-tearing
riverctl rule-del [-app-id <glob>|-title <glob>] <action>
riverctl list-rules float|ssd|tags|position|dimensions|fullscreen
```

#### Visual Configuration

```sh
riverctl background-color 0xRRGGBB[AA]
riverctl border-color-focused 0xRRGGBB[AA]
riverctl border-color-unfocused 0xRRGGBB[AA]
riverctl border-color-urgent 0xRRGGBB[AA]
riverctl border-width <pixels>
```

#### Behavior Configuration

```sh
riverctl focus-follows-cursor disabled|normal|always
riverctl hide-cursor timeout <ms>
riverctl hide-cursor when-typing enabled|disabled
riverctl set-cursor-warp disabled|on-output-change|on-focus-change
riverctl set-repeat <rate> <delay>
riverctl xcursor-theme <theme_name> [size]
riverctl default-attach-mode top|bottom|above|below|after <N>
riverctl output-attach-mode top|bottom|above|below|after <N>
riverctl allow-tearing enabled|disabled
```

#### Input Device Configuration

```sh
riverctl list-inputs                              # Show all input devices
riverctl list-input-configs                       # Show all input configs
riverctl keyboard-layout [-rules r] [-model m] [-variant v] [-options o] <layout>
riverctl keyboard-layout-file <path>
riverctl input <name> events enabled|disabled|disabled-on-external-mouse
riverctl input <name> accel-profile none|flat|adaptive
riverctl input <name> pointer-accel <factor>      # -1.0 to 1.0
riverctl input <name> click-method none|button-areas|clickfinger
riverctl input <name> drag enabled|disabled
riverctl input <name> drag-lock enabled|disabled
riverctl input <name> disable-while-typing enabled|disabled
riverctl input <name> disable-while-trackpointing enabled|disabled
riverctl input <name> middle-emulation enabled|disabled
riverctl input <name> natural-scroll enabled|disabled
riverctl input <name> scroll-factor <factor>
riverctl input <name> left-handed enabled|disabled
riverctl input <name> tap enabled|disabled
riverctl input <name> tap-button-map left-right-middle|left-middle-right
riverctl input <name> scroll-method none|two-finger|edge|button
riverctl input <name> scroll-button <button>
riverctl input <name> scroll-button-lock enabled|disabled
riverctl input <name> map-to-output <output>|disabled
```

---

## River 0.4+ (Modular)

### Architectural Changes

River 0.4 is a fundamental overhaul. The compositor handles rendering, Wayland protocols, and Xwayland. Window management (positioning, focus, bindings, decorations) is delegated to an external window manager via the `river-window-management-v1` protocol.

Key properties:
- Window managers can be **hot-swapped** without losing the session
- Only one WM client is active at a time
- Frame-perfect state changes via alternating manage/render sequences
- The compositor retains control of input config, output config, and cursor theming
- Within ~6 weeks of publishing the protocol, at least **13 independent window managers** were written

### What Changes for Users

| Concern | Classic | 0.4+ |
|---|---|---|
| Keybindings | `riverctl map` in init script | Defined by the chosen WM |
| Layouts | External layout generator (rivertile, wideriver, etc.) | Handled by the WM directly |
| Tags/Workspaces | 32-bit tag bitfield via `riverctl` | Depends on WM (some use tags, some use workspaces) |
| Window rules | `riverctl rule-add` | Depends on WM |
| Borders/Colors | `riverctl border-color-*` | Some WMs handle their own borders |
| Status bar | river-status protocol -> waybar/yambar | WM-specific status protocols or built-in bars |

### What Stays the Same

- Input device configuration (`riverctl input`)
- Output configuration
- Cursor theming
- XWayland support
- XDG portal setup
- Session/systemd integration

---

## Migration Plan: Classic to 0.4+

### Prerequisites

1. River 0.4+ available in nixpkgs (or packaged via flake input)
2. A chosen window manager packaged and available
3. Understanding of the chosen WM's configuration format

### Step-by-step Migration

#### 1. Choose a Window Manager

See the [Window Managers section](#window-managers-for-river-04) below. Key considerations:
- **kwm** if you want dwm-like behavior with a built-in bar
- **beansprout** if you want dwm-style tiling with built-in wallpaper/clock
- **rrwm** if you want bspwm/cosmic-style layouts
- **rill** if you want scrolling tiling with animations
- **zrwm** if you want CLI-configured dynamic tiling (closest to river-classic UX)
- **pwm** if you want Python scriptability
- **kuskokwim** if you want composable keybindings and process management

#### 2. Package River 0.4+ (if not in nixpkgs)

Add a flake input in `modules/river/river.nix`:

```nix
flake-file.inputs.river = {
  url = "github:riverwm/river";         # or codeberg mirror
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```

Then use `inputs.river.packages.${system}.default` as the package.

#### 3. Package the Chosen WM

Most River 0.4+ WMs are on GitHub/Codeberg. Example for zrwm:

```nix
flake-file.inputs.zrwm = {
  url = "github:user/zrwm";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```

Or package from source in the aspect file using `pkgs.buildZigPackage`, `pkgs.rustPlatform.buildRustPackage`, etc.

#### 4. Update the NixOS Module

River 0.4+ may not have a dedicated NixOS module yet. You'd need to:

```nix
nixos = { pkgs, ... }: {
  # Manual session registration (if no NixOS module exists)
  environment.systemPackages = [ river-04-package ];
  services.displayManager.sessionPackages = [ river-04-package ];

  # XDG portals (same as classic)
  xdg.portal = {
    enable = true;
    config.river.default = [ "wlr" "gtk" ];
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };
};
```

#### 5. Restructure the Home Manager Config

The HM `wayland.windowManager.river` module is designed for river-classic. For 0.4+, you'd likely use raw config files:

```nix
homeManager = { pkgs, ... }: {
  # River 0.4+ init script (compositor-level config only)
  xdg.configFile."river/init" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Input configuration (stays with compositor)
      riverctl input "*" tap enabled
      riverctl input "*" natural-scroll disabled
      riverctl set-repeat 25 300

      # Start the window manager
      exec zrwm  # or whichever WM you chose
    '';
  };

  # WM-specific config (varies by WM)
  xdg.configFile."zrwm/config" = { ... };
};
```

#### 6. Translate Configuration

Map your current river-classic config to the new WM:

| Classic concept | 0.4+ equivalent |
|---|---|
| `riverctl map` keybindings | WM keybinding config |
| `riverctl set-focused-tags` | WM workspace/tag switching |
| `riverctl rule-add` window rules | WM window rules |
| `riverctl border-color-*` | WM border config (or compositor if WM defers) |
| `riverctl default-layout` + wideriver | WM's built-in layout engine |
| Scratchpad tag tricks | WM-specific scratchpad (if available) |
| `riverctl spawn` autostart | WM autostart or compositor init |

#### 7. Update thinkpad.nix

```nix
session = "/home/${username}/.nix-profile/bin/river";  # stays the same binary name
```

The `den.aspects.river` include stays the same — only the internal implementation changes.

#### 8. Testing Strategy

Since WMs can be hot-swapped in 0.4+, you can:
1. Start River 0.4+
2. Launch a WM
3. If it doesn't work, Ctrl+Alt+F2 to a TTY and kill the WM
4. Try a different WM without restarting River

---

## Window Managers for River 0.4+

All of these implement the `river-window-management-v1` protocol.

### beansprout

- **Style**: DWM-style tiling
- **Language**: Unknown
- **Config**: Kdl format
- **Features**: Built-in wallpaper rendering, built-in clock display on desktop
- **URL**: Check Codeberg/GitHub for latest

### Canoe

- **Style**: Stacking (floating) window manager
- **Language**: Rust
- **Config**: Unknown
- **Features**: Classic desktop look with overlapping windows, title bars
- **Notes**: Unique among River WMs — most are tiling. Good for users who prefer a traditional desktop

### kuskokwim

- **Style**: Tiling
- **Language**: Python
- **Config**: Python-based
- **Features**: Composable keybindings, process management, scriptable
- **Notes**: Python runtime allows complex scripting and dynamic behavior

### kwm

- **Style**: DWM-like dynamic tiling
- **Language**: Zig
- **Config**: Unknown
- **Features**: Scrollable-tiling mode, built-in status bar
- **Notes**: Written in Zig like River itself. Built-in bar eliminates need for waybar/yambar

### machi

- **Style**: Minimalist
- **Language**: Unknown
- **Config**: Unknown
- **Features**: Cascading windows, horizontal panels
- **Notes**: Minimalist approach, fewer features but simpler mental model

### mousetrap

- **Style**: Minimal, stumpwm/ratpoison-like
- **Language**: C++
- **Config**: Unknown
- **Features**: Keyboard-driven, minimal UI chrome
- **Notes**: For users who want the absolute minimum — like ratpoison for Wayland

### pwm

- **Style**: Tiling
- **Language**: Unknown (Python API)
- **Config**: Python scripting
- **Features**: Server-side decoration titlebars, full Python API for scripting
- **Notes**: Best option for extensive scripting and customization. SSD titlebars are unique

### rhine

- **Style**: BSP (binary space partition) layout tiling
- **Language**: Unknown
- **Config**: Unknown
- **Features**: BSP layouts, Hyprland IPC compatibility for status bars
- **Notes**: If you want BSP tiling (like bspwm) AND want to use Hyprland-compatible bars, this is the one

### rijan

- **Style**: Small dynamic tiling
- **Language**: Janet (Lisp dialect)
- **Config**: Janet scripting
- **Features**: Entire WM in ~600 lines of code
- **Notes**: Extremely minimal. Janet is a lightweight Lisp — good for Lisp enthusiasts

### rill

- **Style**: Scrolling window manager
- **Language**: Zig
- **Config**: Unknown
- **Features**: Scrolling tiling (like Niri/PaperWM), smooth animations
- **Notes**: If you like Niri's scrolling paradigm but want River's compositor. Written in Zig

### rrwm

- **Style**: Tiling with cosmic/bspwm layout
- **Language**: Rust
- **Config**: Unknown
- **Features**: COSMIC-style or bspwm-style layout engine
- **Notes**: Rust-based, modern layout algorithms

### tarazed

- **Style**: Non-tiling, distraction-free
- **Language**: Unknown
- **Config**: Unknown
- **Features**: Distraction-free desktop, no tiling
- **Notes**: Intentionally avoids tiling. For users who want a minimal, focused environment

### zrwm

- **Style**: Dynamic tiling
- **Language**: Unknown
- **Config**: CLI commands (like riverctl)
- **Features**: Configured via CLI, dynamic tiling
- **Notes**: Closest to the river-classic experience — CLI-driven configuration. Easiest migration path

### Comparison Matrix

| WM | Tiling | Floating | Built-in Bar | Config Format | Language | Scratchpad | BSP |
|---|---|---|---|---|---|---|---|
| beansprout | Yes | - | Clock only | Kdl | - | - | - |
| Canoe | No | Yes | - | - | Rust | - | - |
| kuskokwim | Yes | - | - | Python | Python | - | - |
| kwm | Yes | - | Yes | - | Zig | - | - |
| machi | Partial | Yes | - | - | - | - | - |
| mousetrap | Manual | - | - | - | C++ | - | - |
| pwm | Yes | - | - | Python | Python | - | - |
| rhine | Yes | - | Hyprland IPC | - | - | - | Yes |
| rijan | Yes | - | - | Janet | Janet | - | - |
| rill | Scrolling | - | - | - | Zig | - | - |
| rrwm | Yes | - | - | - | Rust | - | Yes |
| tarazed | No | Yes | - | - | - | - | - |
| zrwm | Yes | - | - | CLI | - | - | - |

### Recommendation for Migration

**zrwm** is the safest migration from river-classic — same CLI-driven config paradigm. **kwm** is the best all-in-one if you want a built-in bar. **rill** if you want to try something different (scrolling tiling). **pwm** if you want deep scripting capabilities.

---

## Layout Generators for River-classic

These implement the `river-layout-v3` protocol. Only relevant for river-classic.

### rivertile (Bundled)

Bundled with river-classic. Simple master-stack layout.

```sh
rivertile -view-padding 6 -outer-padding 6 -main-location left -main-count 1 -main-ratio 0.6 &
```

Runtime commands:
```sh
riverctl send-layout-cmd rivertile "main-location left|right|top|bottom"
riverctl send-layout-cmd rivertile "main-count +1|-1"
riverctl send-layout-cmd rivertile "main-ratio +0.05|-0.05"
```

### rivercarro (nixpkgs: `pkgs.rivercarro`)

Fork of rivertile with additional features:
- Monocle layout
- Smart gaps (auto-hide with single view)
- Runtime gap adjustment
- Width limiting
- Per-tag configurations
- Layout cycling (`main-location-cycle`)

```sh
rivercarro -inner-gaps 4 -outer-gaps 4 -main-ratio 0.55 &
riverctl send-layout-cmd rivercarro "main-location-cycle left,monocle"
```

### wideriver (nixpkgs: `pkgs.wideriver`)

Most feature-rich layout generator:
- Layouts: left, right, top, bottom, **wide** (centered master), monocle
- Stack modes: even, diminish, dwindle
- Per-tag state persistence
- Smart gaps
- Per-layout border widths and colors
- Monocle view count display
- Layout toggling between primary and alt layout

```sh
wideriver \
  --layout wide \
  --layout-alt monocle \
  --stack dwindle \
  --count-master 1 \
  --ratio-master 0.50 \
  --ratio-wide 0.35 \
  --inner-gaps 7 \
  --outer-gaps 0 \
  --smart-gaps \
  --border-width 4 \
  --border-width-monocle 0 \
  --border-color-focused 0x89b4fa \
  --border-color-unfocused 0x45475a \
  &

riverctl send-layout-cmd wideriver "--layout-toggle"
riverctl send-layout-cmd wideriver "--ratio +0.05"
riverctl send-layout-cmd wideriver "--count +1"
riverctl send-layout-cmd wideriver "--stack dwindle"
```

### filtile (nixpkgs: `pkgs.river-filtile`)

Drop-in rivertile replacement with per-tag configuration and smart gaps. Replace all instances of `rivertile` with `filtile` in your config.

### river-bsp-layout (nixpkgs: `pkgs.river-bsp-layout`)

Binary space partition / grid layout.

### Others (may need packaging)

| Generator | Description |
|---|---|
| river-luatile | Write layouts in Lua |
| kile | Lisp-like layout syntax |
| riverguile | Guile Scheme layouts |
| riverdeck | Fork of rivercarro adding deck and grid layouts |
| river-ultitile | Main/stack with automatic centering on widescreens |
| river-dwindle | Spiral layouts |
| stacktile | Sublayouts arranged in a metalayout (Zig-based) |

---

## Status Bars

### Waybar (Native River Support)

Four dedicated River modules:

**river/tags** — Tag indicator with click-to-switch:
```json
{
  "river/tags": {
    "num-tags": 9,
    "tag-labels": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
    "disable-click": false,
    "hide-vacant": false
  }
}
```
CSS: `#tags button`, `.occupied`, `.focused`, `.urgent`

**river/window** — Focused window title:
```json
{ "river/window": { "format": "{}", "max-length": 50 } }
```

**river/layout** — Current layout name:
```json
{ "river/layout": { "format": "{}", "min-length": 4, "align": "right" } }
```

**river/mode** — Current input mode:
```json
{ "river/mode": { "format": "mode: {}" } }
```

### Other Bars

| Bar | Description | River Support |
|---|---|---|
| yambar | Lightweight modular bar | Since v1.5.0 |
| levee | Dedicated River statusbar | Native |
| creek | Lightweight dwm-like bar | Native |
| i3bar-river | i3bar ported to River | Native |
| sandbar | dwm-inspired bar | Native |
| dam | Minimal dwm-style bar | Native |
| zelbar | Compositor-agnostic, reads STDIN | Universal |
| eww | ElKowar's Wacky Widgets | Universal |

### Status Information Tools

| Tool | Description |
|---|---|
| ristate | River status as JSON (for custom scripts/bars) |
| river-bedload | River info as JSON |
| riverwm-utils | Tag navigation and cycling utilities |

---

## Ecosystem Tools

### Output/Display

| Tool | Description | nixpkgs |
|---|---|---|
| kanshi | Auto-switching output profiles | Yes |
| wlr-randr | Simple output configuration | Yes |
| way-displays | Hotplug-aware display management | Yes |
| wdisplays | GUI monitor configuration | Yes |
| wlopm | Output power management (DPMS) | Yes |

### Program Launchers

| Tool | Description | nixpkgs |
|---|---|---|
| fuzzel | Rofi drun-mode alternative | Yes |
| bemenu | dmenu-inspired dynamic menu | Yes |
| wofi | GTK-based launcher | Yes |
| tofi | Tiny dynamic menu | Yes |
| wmenu | Efficient dmenu clone | Yes |
| nwg-drawer | GNOME-style app drawer | Yes |

### Notification Daemons

| Tool | Description | nixpkgs |
|---|---|---|
| mako | Lightweight notification daemon | Yes |
| dunst | Highly customizable | Yes |
| fnott | Keyboard-driven, lightweight | Yes |
| SwayNotificationCenter | GTK, with control center | Yes |

### Wallpaper

| Tool | Description | nixpkgs |
|---|---|---|
| swaybg | Basic wallpaper | Yes |
| swww | Animated wallpaper transitions | Yes |
| wbg | Super simple wallpaper | Yes |
| waypaper | GUI wallpaper manager | Yes |

### Screen Lock / Idle

| Tool | Description | nixpkgs |
|---|---|---|
| waylock | Small screenlocker (by River author) | Yes |
| swaylock | i3lock clone for Wayland | Yes |
| swayidle | Idle manager | Yes |

### Screenshot / Recording

| Tool | Description | nixpkgs |
|---|---|---|
| grim | Screenshot utility | Yes |
| slurp | Region selection | Yes |
| wayshot | Screenshot tool | Yes |
| wf-recorder | Screen recording | Yes |
| wl-screenrec | High-performance recording | Yes |

### Clipboard / Utilities

| Tool | Description | nixpkgs |
|---|---|---|
| wl-clipboard | Clipboard management (wl-copy/wl-paste) | Yes |
| wtype | Virtual keyboard (password managers) | Yes |
| wob | Lightweight overlay bar (volume/brightness) | Yes |
| lswt | List Wayland toplevels | Yes |

### River-specific Utilities

| Tool | Description |
|---|---|
| ristate | River status as JSON |
| river-bedload | River info as JSON |
| riverwm-utils | Tag navigation/cycling |
| river-shifttags | Tag navigation |
| river-tag-overlay | Visual tag indicator overlay |
| flow | River control utility with extras |
| multi_tag_switcher | Multi-tag switching |
| swhkd | sxhkd clone for Wayland (global hotkeys) |
| channel | Runtime-reloaded input config (River 0.4+) |

---

## Wayland Protocols

### river-layout-v3 (River-classic only)

Allows external layout generators to specify window dimensions and positions.

Interfaces:
- `river_layout_manager_v3`: Creates layout objects per output namespace
- `river_layout_v3`: Receives layout demands, pushes view dimensions, commits

Workflow: receive demand -> calculate positions -> push dimensions -> commit

### river-control-unstable-v1 (River-classic only)

Programmatic `riverctl` access — send commands, get success/failure responses.

### river-status-unstable-v1 (River-classic only)

Provides tag states, focused view titles, output info. Used by waybar and other status bars.

### river-window-management-v1 (River 0.4+ only)

The protocol enabling modular window management.

Key properties:
- Frame-perfect state changes via alternating manage/render sequences
- Separates window management state from rendering state
- Only one WM client active at a time

Interfaces:
- `river_window_v1`: Individual window control
- `river_seat_v1`: Seat/input management
- `river_node_v1`: Window tree nodes
- `river_output_v1`: Output info
- `river_shell_surface_v1`: Shell surface management

---

## Tags System

River uses a **32-bit bitfield** for tags, fundamentally different from traditional workspaces. Each output has a focused-tags bitfield, and each window (view) has its own tags bitfield.

A window is visible if `(output.focused_tags & window.tags) > 0` — at least one bit matches.

### Tag Arithmetic

```sh
tag_1=$((1 << 0))    # = 1   = binary 00001
tag_2=$((1 << 1))    # = 2   = binary 00010
tag_3=$((1 << 2))    # = 4   = binary 00100
tag_1_and_3=$(( (1 << 0) | (1 << 2) ))  # = 5 = binary 00101
all_tags=$(((1 << 32) - 1))              # all 32 bits set
```

### Key Insight

Unlike workspaces, you can show multiple tags simultaneously. Setting `focused-tags` to `$((tag_1 | tag_3))` shows windows from both tag 1 and tag 3 together. Toggling adds/removes individual tags from the current view.

### Common Keybinding Pattern

```sh
for i in $(seq 1 9); do
    tags=$((1 << ($i - 1)))
    riverctl map normal Super $i set-focused-tags $tags
    riverctl map normal Super+Shift $i set-view-tags $tags
    riverctl map normal Super+Control $i toggle-focused-tags $tags
    riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
done
all_tags=$(((1 << 32) - 1))
riverctl map normal Super 0 set-focused-tags $all_tags
riverctl map normal Super+Shift 0 set-view-tags $all_tags
```

---

## Scratchpad Patterns

### Single Scratchpad (Using a High Tag)

```sh
scratch_tag=$((1 << 20))

# Toggle scratchpad visibility
riverctl map normal Super P toggle-focused-tags ${scratch_tag}

# Send focused window to scratchpad
riverctl map normal Super+Shift P set-view-tags ${scratch_tag}

# Prevent new windows from spawning on scratchpad tag
all_but_scratch=$(( ((1 << 32) - 1) ^ $scratch_tag ))
riverctl spawn-tagmask ${all_but_scratch}
```

### Per-app Scratchpads (Multiple High Tags)

Assign each scratchpad app its own tag bit and use window rules to route them:

```sh
kitty_tag=$((1 << 21))
onepass_tag=$((1 << 22))

# Window rules
riverctl rule-add -app-id "kitty-dropterm" tags $kitty_tag
riverctl rule-add -app-id "kitty-dropterm" float
riverctl rule-add -app-id "1password" tags $onepass_tag
riverctl rule-add -app-id "1password" float

# Toggle keybinds
riverctl map normal Super Grave toggle-focused-tags $kitty_tag
riverctl map normal Super+Shift O toggle-focused-tags $onepass_tag

# Exclude from spawn-tagmask
all_scratch=$(( kitty_tag | onepass_tag ))
all_tags=$(( (1 << 32) - 1 ))
riverctl spawn-tagmask $(( all_tags ^ all_scratch ))
```

### Sticky Windows (Visible on All Tags)

```sh
all_tags=$(((1 << 32) - 1))
sticky_tag=$((1 << 31))
all_but_sticky=$(( all_tags ^ sticky_tag ))

# Toggle sticky on focused window
riverctl map normal Super S toggle-view-tags $sticky_tag

# Prevent new windows from getting sticky tag
riverctl spawn-tagmask $all_but_sticky

# Always include sticky tag when switching workspaces
for i in $(seq 1 9); do
    tags=$((1 << (i - 1)))
    riverctl map normal Super $i set-focused-tags $(($sticky_tag + $tags))
done
```

---

## NixOS Integration

### NixOS Module (nixpkgs 25.11)

```nix
programs.river-classic = {
  enable = true;
  package = pkgs.river-classic;  # set null if using HM module
  xwayland.enable = true;        # default true
  extraPackages = with pkgs; [ swaylock foot dmenu ];
};
```

Provides: display manager session, XDG portal config (wlr + gtk), Wayland session env, polkit.

### Home Manager Module

```nix
wayland.windowManager.river = {
  enable = true;
  package = pkgs.river-classic;  # nullable
  xwayland.enable = true;

  systemd = {
    enable = true;
    variables = [ "--all" ];
    extraCommands = [
      "systemctl --user stop river-session.target"
      "systemctl --user start river-session.target"
    ];
  };

  extraSessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  settings = {
    border-width = 2;
    declare-mode = [ "locked" "normal" "passthrough" ];
    set-repeat = "50 300";
    background-color = "0x002b36";
    border-color-focused = "0x93a1a1";
    border-color-unfocused = "0x586e75";
    map.normal."Super Q" = "close";
    map.normal."Super Return" = "spawn foot";
    input."pointer-foo-bar" = {
      accel-profile = "flat";
      pointer-accel = -0.3;
      tap = false;
    };
    rule-add."-app-id" = {
      "'bar'" = "csd";
      "'float*'"."-title"."'foo'" = "float";
    };
    spawn = [ "firefox" "'foot -a terminal'" ];
  };

  extraConfig = ''
    rivertile -view-padding 6 -outer-padding 6 &
  '';
};
```

The `settings` attrset is recursively converted to `riverctl` commands. Booleans become `enabled`/`disabled`, numbers become strings, attrsets recurse into subcommands.

The module creates a `river-session.target` systemd user target bound to `graphical-session.target`.

### Portal Setup

The NixOS module handles this automatically. Manual equivalent:

```nix
xdg.portal = {
  enable = true;
  config.river.default = [ "wlr" "gtk" ];
  extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];
};
```

### Systemd Session

```sh
# In init script (HM module does this automatically):
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river DISPLAY
systemctl --user stop river-session.target
systemctl --user start river-session.target
```

### Environment Variables

```sh
export XDG_CURRENT_DESKTOP=river
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export NIXOS_OZONE_WL=1
export XCURSOR_THEME=<theme_name>
export XCURSOR_SIZE=24
```

### GTK Decoration Workarounds

River supports SSD via `riverctl rule-add ssd`. For CSD apps showing unwanted titlebars:

- Firefox: Customize Toolbar > uncheck Title Bar
- GTK3/4: Add to `~/.config/gtk-3.0/gtk.css` and `gtk-4.0/gtk.css`:
  ```css
  headerbar { display: none; }
  window decoration { margin: 0; border: none; padding: 0; box-shadow: none; }
  ```

### Troubleshooting

- **Display issues**: Try `export WLR_DRM_NO_MODIFIERS=1`
- **Screencasting**: Ensure `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` are exported to systemd/D-Bus
- **Cursor themes**: Set `XCURSOR_THEME` and `XCURSOR_SIZE` env vars
- **No config reload**: River has no reload mechanism — run individual `riverctl` commands interactively for testing

---

## Sources

- [River-classic wiki](https://codeberg.org/river/wiki-classic)
- [River (0.4+) repository](https://codeberg.org/river/river)
- [River-classic repository](https://codeberg.org/river/river-classic)
- [ArchWiki - River](https://wiki.archlinux.org/title/River)
- [Gentoo Wiki - River](https://wiki.gentoo.org/wiki/River)
- [riverctl man page](https://www.mankier.com/1/riverctl)
- [River window management protocol](https://isaacfreund.com/docs/wayland/river-window-management-v1)
- [River intro blog post](https://isaacfreund.com/blog/river-intro/)
- [The Register - River modular WMs](https://www.theregister.com/2026/02/11/river_wayland_with_wms/)
- [wideriver](https://github.com/alex-courtis/wideriver)
- [rivercarro](https://git.sr.ht/~novakane/rivercarro)
