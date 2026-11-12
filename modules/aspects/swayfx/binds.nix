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
      {
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        screenshotAnnotate = pkgs.writeShellScript "screenshot-annotate" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          FILE=$(mktemp /tmp/screenshot-XXXXXX.png)
          ${
            pkgs.sway-contrib.grimshot.override { sway-unwrapped = osConfig.programs.sway.package; }
          }/bin/grimshot save area "$FILE" && satty --filename "$FILE" --output-filename "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          rm -f "$FILE"
        '';
      in
      {
        wayland.windowManager.sway.config = {
          keybindings =
            let
              mod = "Mod4";
              swayMods = {
                none = "";
                super = "${mod}+";
                "super+shift" = "${mod}+Shift+";
              };
              dmsBinds = lib.listToAttrs (
                map (b: lib.nameValuePair "${swayMods.${b.mods}}${b.key}" "exec ${b.cmd}") (
                  import ../wayland/_dms-binds.nix
                )
              );
              workspaceBinds = lib.listToAttrs (
                lib.concatMap (
                  n:
                  let
                    s = toString n;
                  in
                  [
                    (lib.nameValuePair "${mod}+${s}" "workspace number ${s}")
                    (lib.nameValuePair "${mod}+Shift+${s}" "move container to workspace number ${s}; workspace number ${s}")
                    (lib.nameValuePair "${mod}+Ctrl+${s}" "move container to workspace number ${s}")
                  ]
                ) (lib.range 1 5)
              );
            in
            lib.mkOptionDefault (
              dmsBinds
              // workspaceBinds
              // {
                # ── App launchers ── (launcher: dmsBinds)
                # replaces the sway default (opens a terminal); mode-aware, see layouts.nix
                "${mod}+Return" = "exec promote-master";
                "${mod}+Shift+Return" = "exec ghostty";
                "${mod}+w" = "exec default-browser";

                # ── Window management ──
                "${mod}+c" = "kill";
                "${mod}+f" = "fullscreen toggle";
                "${mod}+Shift+f" = "floating toggle";

                # ── Focus last / urgent (Hyprland: focuscurrentorlast / focusurgentorlast) ──
                "${mod}+x" = "exec swayr switch-to-urgent-or-lru-window";
                "${mod}+u" = "[urgent=latest] focus";

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
                # 1-5 view / move+follow / move silent: workspaceBinds above

                # ── Scratchpad: Mod+N minimizes or restores; Mod+Shift+N shows overlay ──
                "${mod}+n" = "exec scratch-smart";
                "${mod}+Shift+n" = "exec scratch-toggle";

                # ── Per-app scratchpads (sway-scratch) ──
                "${mod}+grave" =
                  ''exec sway-scratch show --app-id kitty-dropterm --exec "kitty --class kitty-dropterm" --resize "set 70 ppt 70 ppt"'';
                "${mod}+Shift+o" =
                  ''exec sway-scratch show --app-id bitwarden --exec bitwarden --resize "set 70 ppt 70 ppt"'';
                "${mod}+Shift+s" =
                  ''exec sway-scratch show --class Slack --exec slack --resize "set 70 ppt 70 ppt"'';
                # Mod+Shift+e matches the Hyprland ente scratchpad bind
                "${mod}+Shift+e" =
                  ''exec sway-scratch show --app-id io.ente.auth --exec enteauth --resize "set 70 ppt 70 ppt"'';
                "${mod}+t" =
                  ''exec sway-scratch show --app-id org.gnome.Nautilus --exec nautilus --resize "set 70 ppt 70 ppt"'';

                # Media/brightness + DMS toggles: dmsBinds (wayland/_dms-binds.nix)

                # ── Alt-Tab ──
                "Mod1+Tab" = "focus next";

                # ── Screenshot ──
                "${mod}+p" = "exec grimshot --notify savecopy screen";
                "${mod}+Ctrl+p" = "exec grimshot --notify savecopy area";
                "${mod}+Mod1+p" = "exec ${screenshotAnnotate}";

                # ── Session ──
                "${mod}+Shift+c" = "reload";
                "${mod}+Shift+q" = "exit";

                # ── Layout management (persway) ──
                "${mod}+m" = "exec layout-switch";
                "${mod}+Tab" = "exec persway stack-focus-next";
                "${mod}+Shift+Tab" = "exec persway stack-focus-prev";
                "${mod}+bracketright" = "exec persway stack-main-rotate-next";

                # ── Remove conflicting defaults ──
                "${mod}+d" = null;
              }
            );
        };
      };
  };
}
