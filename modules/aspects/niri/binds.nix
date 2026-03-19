# Niri keybindings — mapped from MangoWC equivalents.
# Collector pattern: merged into den.aspects.niri by den.
#
# Key differences from MangoWC:
#   - H/L scroll columns (horizontal strip), J/K move between windows in column or workspaces
#   - Mod+R cycles preset column widths, Ctrl+H/L for fine resize
#   - Mod+Comma/Period consume/expel windows into/from columns (niri-unique)
#   - Workspaces are a vertical stack (dynamic), not numbered tags
#   - Parameterless actions use `= [];` syntax (niri-flake type requirement)
{
  den.aspects.niri = {
    homeManager.programs.niri.settings.binds = {
      # ── Application launchers ──
      "Mod+P".action.spawn = [
        "rofi"
        "-show"
        "drun"
      ];
      "Mod+Q".action.spawn = "ghostty";
      "Mod+W".action.spawn = "zen-beta";
      "Mod+T".action.spawn = "thunar";

      # ── Window management ──
      "Mod+C".action.close-window = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.spawn = "nfsm-cli"; # nfsm: fullscreen with position restore

      # ── Column navigation (niri's horizontal strip) ──
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+K".action.focus-window-or-workspace-up = [ ];
      "Mod+J".action.focus-window-or-workspace-down = [ ];

      # ── Move windows ──
      "Mod+Shift+H".action.move-column-left = [ ];
      "Mod+Shift+L".action.move-column-right = [ ];
      "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [ ];
      "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [ ];

      # ── Resize ──
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+H".action.set-column-width = "-5%";
      "Mod+Ctrl+L".action.set-column-width = "+5%";
      "Mod+Ctrl+K".action.set-window-height = "-5%";
      "Mod+Ctrl+J".action.set-window-height = "+5%";

      # ── Workspace navigation ──
      "Mod+Z".action.focus-workspace-previous = [ ];
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;

      # ── Move column to workspace ──
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;

      # ── Column operations (niri-unique) ──
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # ── Floating ──
      "Mod+Shift+Space".action.toggle-window-floating = [ ];

      # ── Alt-Tab ──
      "Alt+Tab".action.focus-column-right = [ ];

      # ── Mouse wheel workspaces ──
      "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
      "Mod+WheelScrollUp".action.focus-workspace-up = [ ];

      # ── Screenshot (niri built-in) ──
      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # ── Scratchpad (Nirius — generic minimize) ──
      # Minimize focused window to scratchpad (bottom workspace)
      "Mod+N".action.spawn = [
        "nirius"
        "scratchpad-toggle"
      ];
      # Show all scratchpad windows on current workspace
      "Mod+Shift+N".action.spawn = [
        "nirius"
        "scratchpad-show-all"
      ];
      # Per-app scratchpad toggles are in plugins.nix (nscratch)

      # ── Session ──
      "Mod+Shift+Q".action.quit.skip-confirmation = true;
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
    };
  };
}
