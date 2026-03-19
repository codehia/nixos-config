# SwayFX keybindings — mapped from Hyprland equivalents.
# Merges into the swayfx aspect via the collector pattern.
#
# Translation notes:
#   Hyprland movefocus    → sway focus <dir>
#   Hyprland movewindow   → sway move <dir>
#   Hyprland resizeactive  → sway resize grow/shrink width/height <n> px
#   Hyprland swapwindow   → sway swap container with <dir>
#   Hyprland killactive   → sway kill
#   Hyprland workspace    → sway workspace number <n>
#   Hyprland movetoworkspace       → sway move container to workspace number <n>; workspace number <n>
#   Hyprland movetoworkspacesilent → sway move container to workspace number <n>
#   Hyprland togglefloating → sway floating toggle
#   Per-app scratchpads via sway-scratch (see scratchpad.nix for packaging)
{
  den.aspects.swayfx = {
    homeManager =
      { lib, ... }:
      {
        wayland.windowManager.sway.config = {
          keybindings =
            let
              mod = "Mod4";
            in
            lib.mkOptionDefault {
              # ── App launchers ──
              "${mod}+space" = "exec dms ipc launcher toggle";
              "${mod}+q" = "exec ghostty";
              "${mod}+w" = "exec zen-beta";

              # ── Window management ──
              "${mod}+c" = "kill";
              "${mod}+f" = "fullscreen toggle";
              "${mod}+Shift+f" = "floating toggle";

              # ── Focus (vim keys) ──
              "${mod}+h" = "focus left";
              "${mod}+l" = "focus right";
              "${mod}+k" = "focus up";
              "${mod}+j" = "focus down";

              # ── Move windows (Shift+vim) ──
              "${mod}+Shift+h" = "move left";
              "${mod}+Shift+l" = "move right";
              "${mod}+Shift+k" = "move up";
              "${mod}+Shift+j" = "move down";

              # ── Resize (Ctrl+vim) ──
              "${mod}+Ctrl+l" = "resize grow width 10 px";
              "${mod}+Ctrl+h" = "resize shrink width 10 px";
              "${mod}+Ctrl+k" = "resize shrink height 10 px";
              "${mod}+Ctrl+j" = "resize grow height 10 px";

              # ── Swap (Alt+vim) ──
              "${mod}+Mod1+h" = "swap container with left";
              "${mod}+Mod1+l" = "swap container with right";
              "${mod}+Mod1+k" = "swap container with up";
              "${mod}+Mod1+j" = "swap container with down";

              # ── Workspaces ──
              "${mod}+z" = "workspace back_and_forth";
              "${mod}+1" = "workspace number 1";
              "${mod}+2" = "workspace number 2";
              "${mod}+3" = "workspace number 3";
              "${mod}+4" = "workspace number 4";
              "${mod}+5" = "workspace number 5";

              # ── Move to workspace + follow ──
              "${mod}+Shift+1" = "move container to workspace number 1; workspace number 1";
              "${mod}+Shift+2" = "move container to workspace number 2; workspace number 2";
              "${mod}+Shift+3" = "move container to workspace number 3; workspace number 3";
              "${mod}+Shift+4" = "move container to workspace number 4; workspace number 4";
              "${mod}+Shift+5" = "move container to workspace number 5; workspace number 5";

              # ── Move to workspace silent (no follow) ──
              "${mod}+Ctrl+1" = "move container to workspace number 1";
              "${mod}+Ctrl+2" = "move container to workspace number 2";
              "${mod}+Ctrl+3" = "move container to workspace number 3";
              "${mod}+Ctrl+4" = "move container to workspace number 4";
              "${mod}+Ctrl+5" = "move container to workspace number 5";

              # ── Scratchpad: Mod+N minimizes or restores; Mod+Shift+N shows overlay ──
              "${mod}+n" = "exec scratch-smart";
              "${mod}+Shift+n" = "exec scratch-toggle";

              # ── Per-app scratchpads (sway-scratch) ──
              "${mod}+grave" =
                ''exec sway-scratch show --app-id kitty-dropterm --exec "kitty --class kitty-dropterm" --resize "set 70 ppt 70 ppt"'';
              "${mod}+Shift+o" =
                ''exec sway-scratch show --app-id 1password --exec "1password --silent" --resize "set 70 ppt 70 ppt"'';
              "${mod}+Shift+m" =
                ''exec sway-scratch show --class Spotify --exec spotify --resize "set 70 ppt 70 ppt"'';
              "${mod}+Shift+s" =
                ''exec sway-scratch show --class Slack --exec slack --resize "set 70 ppt 70 ppt"'';
              "${mod}+e" =
                ''exec sway-scratch show --app-id io.ente.auth --exec enteauth --resize "set 70 ppt 70 ppt"'';
              "${mod}+t" = ''exec sway-scratch show --app-id thunar --exec thunar --resize "set 70 ppt 70 ppt"'';

              # ── Media / brightness ──
              "F1" = "exec dms ipc audio mute";
              "F2" = "exec dms ipc audio decrement 5";
              "F3" = "exec dms ipc audio increment 5";
              "F4" = "exec dms ipc audio micmute";
              "F5" = "exec dms ipc brightness decrement 10 backlight:amdgpu_bl1";
              "F6" = "exec dms ipc brightness increment 10 backlight:amdgpu_bl1";

              # ── DMS toggles ──
              "${mod}+Shift+p" = "exec dms ipc powermenu toggle";
              "${mod}+Shift+d" = "exec dms ipc notifications toggleDoNotDisturb";
              "${mod}+Shift+i" = "exec dms ipc notepad toggle";
              "${mod}+Shift+v" = "exec dms ipc clipboard toggle";
              "${mod}+Shift+b" = "exec dms ipc notifications toggle";
              "${mod}+Shift+g" = "exec dms ipc control-center toggle";

              # ── Alt-Tab ──
              "Mod1+Tab" = "focus next";

              # ── Screenshot ──
              "Print" = "exec grim - | wl-copy";
              "Ctrl+Print" = ''exec grim -g "$(slurp)" - | wl-copy'';

              # ── Session ──
              "${mod}+Shift+c" = "reload";
              "${mod}+Shift+q" = "exit";

              # ── Layout management (persway) ──
              "${mod}+m" = "exec layout-switch";
              "${mod}+Return" = "exec promote-master";
              "${mod}+Tab" = "exec persway stack-focus-next";
              "${mod}+Shift+Tab" = "exec persway stack-focus-prev";
              "${mod}+bracketright" = "exec persway stack-main-rotate-next";

              # ── Remove conflicting defaults ──
              "${mod}+d" = null;
            };
        };
      };
  };
}
