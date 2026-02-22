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
{...}: {
  den.aspects.swayfx = {
    homeManager = {lib, ...}: {
      wayland.windowManager.sway.config = {
        keybindings = let
          mod = "Mod4";
        in
          lib.mkOptionDefault {
            # ── App launchers ──
            "${mod}+p" = "exec rofi -show drun";
            "${mod}+q" = "exec ghostty";
            "${mod}+w" = "exec zen-beta";
            "${mod}+t" = "exec thunar";

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

            # ── Native scratchpad (minimize/restore) ──
            "${mod}+n" = "scratchpad show";
            "${mod}+Shift+n" = "move scratchpad";

            # ── Per-app scratchpads (sway-scratch) ──
            "${mod}+grave" = ''exec sway-scratch show --app-id kitty-dropterm --exec "kitty --class kitty-dropterm" --resize "set 70 ppt 70 ppt"'';
            "${mod}+Shift+o" = ''exec sway-scratch show --app-id 1password --exec "1password --silent"'';
            "${mod}+Shift+m" = ''exec sway-scratch show --app-id spotify --exec spotify'';
            "${mod}+Shift+s" = ''exec sway-scratch show --class Slack --exec slack'';
            "${mod}+Shift+e" = ''exec sway-scratch show --app-id "Ente Auth" --exec enteauth'';
            "${mod}+Shift+t" = ''exec sway-scratch show --app-id thunar --exec thunar --resize "set 70 ppt 70 ppt"'';

            # ── Alt-Tab ──
            "Mod1+Tab" = "focus next";

            # ── Screenshot ──
            "Print" = "exec grim - | wl-copy";
            "Ctrl+Print" = ''exec grim -g "$(slurp)" - | wl-copy'';

            # ── Session ──
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+q" = "exit";

            # ── Remove conflicting defaults ──
            "${mod}+Return" = null;
            "${mod}+d" = null;
          };
      };
    };
  };
}
