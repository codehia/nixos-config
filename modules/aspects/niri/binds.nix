# Niri keybindings — canonical Hyprland scheme wherever niri has an equivalent.
# Collector pattern: merged into den.aspects.niri by den.
#
# Niri-unique deviations (documented, no Hyprland equivalent):
#   - H/L scroll columns (horizontal strip), J/K move between windows in column or workspaces
#   - Mod+R cycles preset column widths, Ctrl+H/L for fine resize
#   - Mod+Comma/Period consume/expel windows into/from columns
#   - Workspaces are a vertical stack (dynamic), not numbered tags
#   - Parameterless actions use `= [];` syntax (niri-flake type requirement)
{
  den.aspects.niri = {
    homeManager =
      { pkgs, ... }:
      let
        # Area screenshot with annotation — niri's built-in screenshot actions can't
        # pipe into satty, so this uses grim/slurp directly.
        screenshotAnnotate = pkgs.writeShellScript "niri-screenshot-annotate" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          FILE=$(mktemp /tmp/screenshot-XXXXXX.png)
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE" \
            && ${pkgs.satty}/bin/satty --filename "$FILE" \
              --output-filename "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          rm -f "$FILE"
        '';
      in
      {
        programs.niri.settings.binds = {
          # ── Application launchers ──
          "Mod+Space".action.spawn = [
            "dms"
            "ipc"
            "launcher"
            "toggle"
          ];
          "Mod+Shift+Return".action.spawn = "ghostty";
          "Mod+W".action.spawn = "zen-beta";
          "Mod+T".action.spawn = "nautilus";

          # ── Window management ──
          "Mod+C".action.close-window = [ ];
          "Mod+F".action.spawn = "nfsm-cli"; # nfsm: fullscreen with position restore
          "Mod+Shift+F".action.toggle-window-floating = [ ];
          "Mod+Shift+Space".action.maximize-column = [ ];

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

          # ── Move column to workspace (follows) ──
          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;

          # ── Move column to workspace silently (stay on current) ──
          "Mod+Ctrl+1".action.move-column-to-workspace = [
            { focus = false; }
            1
          ];
          "Mod+Ctrl+2".action.move-column-to-workspace = [
            { focus = false; }
            2
          ];
          "Mod+Ctrl+3".action.move-column-to-workspace = [
            { focus = false; }
            3
          ];
          "Mod+Ctrl+4".action.move-column-to-workspace = [
            { focus = false; }
            4
          ];
          "Mod+Ctrl+5".action.move-column-to-workspace = [
            { focus = false; }
            5
          ];

          # ── Column operations (niri-unique) ──
          "Mod+Comma".action.consume-window-into-column = [ ];
          "Mod+Period".action.expel-window-from-column = [ ];

          # ── Alt-Tab ──
          "Alt+Tab".action.focus-column-right = [ ];

          # ── Mouse wheel workspaces ──
          "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
          "Mod+WheelScrollUp".action.focus-workspace-up = [ ];

          # ── Screenshot (niri built-ins; annotate via grim/slurp — grimblast is Hyprland-only) ──
          "Mod+P".action.screenshot-screen = [ ];
          "Mod+Ctrl+P".action.screenshot = [ ];
          "Mod+Alt+P".action.spawn = "${screenshotAnnotate}";

          # ── Media / brightness (DMS) ──
          "F1".action.spawn = [
            "dms"
            "ipc"
            "audio"
            "mute"
          ];
          "F2".action.spawn = [
            "dms"
            "ipc"
            "audio"
            "decrement"
            "5"
          ];
          "F3".action.spawn = [
            "dms"
            "ipc"
            "audio"
            "increment"
            "5"
          ];
          "F4".action.spawn = [
            "dms"
            "ipc"
            "audio"
            "micmute"
          ];
          "F5".action.spawn = [
            "dms"
            "ipc"
            "brightness"
            "decrement"
            "10"
            "backlight:amdgpu_bl1"
          ];
          "F6".action.spawn = [
            "dms"
            "ipc"
            "brightness"
            "increment"
            "10"
            "backlight:amdgpu_bl1"
          ];

          # ── DMS toggles ──
          "Mod+Shift+P".action.spawn = [
            "dms"
            "ipc"
            "powermenu"
            "toggle"
          ];
          "Mod+Shift+D".action.spawn = [
            "dms"
            "ipc"
            "notifications"
            "toggleDoNotDisturb"
          ];
          "Mod+Shift+I".action.spawn = [
            "dms"
            "ipc"
            "notepad"
            "toggle"
          ];
          "Mod+Shift+V".action.spawn = [
            "dms"
            "ipc"
            "clipboard"
            "toggle"
          ];
          "Mod+Shift+B".action.spawn = [
            "dms"
            "ipc"
            "notifications"
            "toggle"
          ];
          "Mod+Shift+G".action.spawn = [
            "dms"
            "ipc"
            "control-center"
            "toggle"
          ];

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
  };
}
