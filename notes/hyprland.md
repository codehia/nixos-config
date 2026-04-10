# Hyprland Configuration — Reference

> Config: `modules/aspects/hyprland/` (collector pattern — multiple files define `den.aspects.hyprland`)

---

## Architecture

| File | Purpose |
|------|---------|
| `hyprland.nix` | NixOS module, packages, all settings (input, general, decorations, workspaces, windowrules) |
| `binds.nix` | All keybindings |
| `_pyprland.nix` | Excluded (`_` prefix) — kept for reference only, pyprland is removed |
| `_hyprpaper.nix` | Excluded — DMS/swww handles wallpapers |

---

## Session Management (UWSM)

**Critical:** NixOS has `programs.hyprland.withUWSM = true`. This means UWSM owns the session.

- HM `wayland.windowManager.hyprland.systemd.enable` **must be `false`** — if both are active they fight over the session and cause startup errors.
- UWSM activates `graphical-session.target`, NOT `hyprland-session.target`. Any systemd user service that depends on `hyprland-session.target` will never start.
- Fix for services: use `systemd.user.services.<name>.Install.WantedBy = lib.mkForce [ "graphical-session.target" ]` (applied to DMS in `dms-home.nix`).

```nix
wayland.windowManager.hyprland.systemd = {
  enable = false;              # UWSM owns session — do not enable
  enableXdgAutostart = true;
  variables = [ "--all" ];
};
```

---

## Theming / Cursor

Stylix owns the cursor (`appearance.nix` — phinger-cursors-light, size 32 via gsettings).

```nix
cursor = {
  sync_gsettings_theme = true;  # picks up stylix cursor automatically
  enable_hyprcursor = true;
  no_hardware_cursors = 2;
};
```

**Do not set cursor env vars** (`HYPRCURSOR_THEME`, `XCURSOR_THEME`, etc.) in Hyprland — phinger-cursors doesn't ship the hyprcursor format, so any explicit theme name will be wrong or missing.

---

## Wallpaper

DMS (swww) handles wallpapers. No hyprpaper needed — `_hyprpaper.nix` is excluded.

---

## Special Workspaces (Scratchpads)

Uses Hyprland's native special workspaces. pyprland was removed (it is a Python daemon, not a `.so` plugin — putting it in `plugins = []` was wrong).

### How it works

```nix
# Lazy launch: app starts only on first toggle
workspace = "special:name, on-created-empty:command"

# Route app to its scratchpad on open (fires once at window creation)
windowrule = "workspace special:name silent, match:class ClassName"

# Toggle show/hide
bind = "$mod, KEY, togglespecialworkspace, name"
```

### Named scratchpads

| Key | Workspace | App | Class |
|-----|-----------|-----|-------|
| `$mod + grave` | `special:term` | `ghostty --class ghostty-term` | `ghostty-term` |
| `$mod SHIFT + T` | `special:filemanager` | `thunar` | `thunar` |
| `$mod SHIFT + O` | `special:pw` | `1password --silent` | `1Password` |
| `$mod SHIFT + M` | `special:spotify` | `spotify` | `Spotify` |
| `$mod SHIFT + S` | `special:slack` | `slack` | `Slack` |
| `$mod SHIFT + E` | `special:ente` | `enteauth` | `io.ente.auth` |

**Note on thunar:** The float/size windowrule targets `class:thunar`, which also affects thunar opened via `$mod + T` (not just the scratchpad). This is intentional.

### Minimized scratchpad (`special:minimized`)

A general-purpose stash for any window. Uses `gapsout:100` to keep windows visually distinct when browsing.

| Key | Action |
|-----|--------|
| `$mod + N` | Send focused window to `special:minimized` |
| `$mod SHIFT + N` | Restore focused window to the active regular workspace, then dismiss |
| `$mod SHIFT + U` | Dismiss (hide) whichever special workspace is currently visible |

**Guard on `$mod + N`:** Checks `hyprctl activewindow -j | .workspace.name` — if it starts with `special:`, the move is skipped. This prevents named scratchpad windows (term, spotify, etc.) from being accidentally stashed in minimized.

**Restore implementation:** Uses `hyprctl monitors -j | .activeWorkspace.id` rather than `activeworkspace` or workspace dispatcher syntax. Reason:
- `activeworkspace` returns the special workspace itself when it's focused — wrong
- `e+0` is not a valid workspace selector (wiki only documents `e+1`, `e-1`, `e~N` — relative to open workspaces)
- `previous` could land on another special workspace
- `monitors[].activeWorkspace` always reflects the underlying regular workspace on the monitor, even when a special workspace is overlaid on top

**Dismiss implementation:** Uses `hyprctl monitors -j | .specialWorkspace.name` to identify which special workspace is visible, then calls `togglespecialworkspace` with its name (stripping the `special:` prefix).

---

## Workspace Dispatcher Syntax (from wiki)

The `workspace` parameter accepts:

| Syntax | Meaning |
|--------|---------|
| `1`, `2`, … | Absolute ID |
| `+1`, `-3` | Relative ID |
| `m+1`, `m~3` | Monitor-relative (skips empty) |
| `r+1`, `r~3` | Monitor-relative (includes empty) |
| `e+1`, `e-1`, `e~2` | Open workspace, relative |
| `name:Web` | By name |
| `previous`, `previous_per_monitor` | Previously focused |
| `empty`, `emptynm` | First available empty |
| `special`, `special:name` | Special workspace — **only valid for `movetoworkspace` / `movetoworkspacesilent`** |

> `e+0` is **not documented** — do not use it.

---

## hyprctl Quick Reference

```bash
hyprctl activewindow -j          # focused window + its workspace name
hyprctl activeworkspace -j       # active workspace (returns special ws when focused — often not what you want)
hyprctl monitors -j              # per-monitor: activeWorkspace (regular) + specialWorkspace (overlay)
hyprctl dispatch <dispatcher> <args>
hyprctl --batch "dispatch X ; dispatch Y"   # chain multiple dispatches
```

Key JSON fields:
- `monitors[].activeWorkspace.id` — underlying regular workspace ID (reliable even with special ws open)
- `monitors[].specialWorkspace.name` — name of visible special workspace, e.g. `special:minimized` (empty string if none)
- `monitors[].focused` — true for the focused monitor
- `activewindow.workspace.name` — workspace the focused window is currently on

---

## Known Issues / Gotchas

**pyprland must not appear in `plugins`**
pyprland is a Python daemon, not a compiled `.so` Hyprland plugin. Start it via `exec-once = ["pypr"]` if ever re-enabled, never via `plugins = []`. Currently removed entirely.

**`hyprland-session.target` never created under UWSM**
UWSM creates `graphical-session.target` instead. Override `WantedBy` with `lib.mkForce` for any affected services.

**Ghostty service fails with `Result: protocol`**
A stray Ghostty process holds the D-Bus name. Fix: `pkill ghostty && systemctl --user start app-com.mitchellh.ghostty.service`. Always launch via the service, never from a shell.

**Ghostty shows random black/blank rows**
Stale fontconfig cache after `just clean`. Fix: `fc-cache -f && systemctl --user restart app-com.mitchellh.ghostty.service`.
