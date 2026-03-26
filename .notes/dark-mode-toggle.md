# DMS Dark Mode Toggle — App Integration Plan

## Mechanism

DMS dark mode toggle writes to:
```
gsettings org.gnome.desktop.interface color-scheme
```
Values: `default` (light) → `prefer-dark` (dark). Confirmed via `gsettings monitor`.

## App Plans

### Thunar / GTK3 apps — easy

**Problem:** `gtk.theme.name = lib.mkForce "adw-gtk3-dark"` is hardcoded, ignores gsettings.

**Fix:** Change to `lib.mkForce "adw-gtk3"` (no `-dark` suffix). adw-gtk3 follows
`org.gnome.desktop.interface color-scheme` natively — no extra config needed.

**Caveat:** This was originally forced to `-dark` because stylix sets the light variant
even with `polarity = "dark"`. With `adw-gtk3` (auto), toggling to light mode will show
the light GTK theme, which is correct behaviour.

**File:** `modules/aspects/stylix.nix` → `gtk.theme.name`

---

### VLC (Qt/Kvantum) — medium

**Problem:** VLC is a Qt app styled by stylix's Qt target (Kvantum). Doesn't follow
gsettings toggle automatically.

**Investigation needed:** Check whether Kvantum is configured to respect
`org.gnome.desktop.interface color-scheme`. Kvantum has a "Follow the color scheme of
the desktop environment" option. May need a Kvantum config file or env var.

**Possible fix:** `QT_QPA_PLATFORMTHEME=gnome` or configuring Kvantum's
`FollowStyleSheet=true` / color scheme tracking in `~/.config/Kvantum/kvantum.kvconfig`.

---

### Zen Browser — medium

**Problem:** Stylix injects static Rose Pine CSS into the Zen profile. This overrides
Zen's own theming with hardcoded colors that don't adapt to dark/light toggle.

**Investigation needed:** Check what exactly `stylix.targets.zen-browser` injects
(userChrome.css? user.js?). Profile is not at `~/.zen` — need to find actual path via
`about:profiles` in Zen.

**Likely fix:** Disable stylix's Zen target (`targets.zen-browser.enable = false`) and
let Zen handle dark mode natively via `prefers-color-scheme`. Zen has its own built-in
dark mode that follows gsettings.

**File:** `modules/aspects/stylix.nix` → `stylix.targets.zen-browser`

---

### Terminals (Ghostty, Kitty) — hard

**Problem:** Colors are injected statically by stylix at build time. No dynamic switching
without matugen (which is disabled in DMS settings) or a custom script.

**Options:**
1. Re-enable matugen in DMS (`runUserMatugenTemplates`, `matugenTemplateGhostty`, etc.) —
   DMS would regenerate terminal configs on theme switch. Complex, may pull in unwanted deps.
2. Write a systemd user service that watches gsettings and rewrites terminal config files.
3. Leave terminals static for now (Rose Pine works for both light and dark contexts).

**Recommendation:** Leave for later unless terminals are a priority.
