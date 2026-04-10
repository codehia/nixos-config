# Hyprland keybindings — merges into the hyprland aspect via the collector pattern.
# den.aspects.hyprland is also defined in hyprland.nix; den merges both definitions.
{ den, ... }:
let
  # Minimize/restore toggle: if special:minimized is visible restore focused window,
  # otherwise send current window to special:minimized.
  hyprMinimizeRestore =
    pkgs:
    pkgs.writeShellScript "hypr-minimize-restore" ''
      ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name')
      if [ "$ws" = "special:minimized" ]; then
        id=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .activeWorkspace.id')
        hyprctl --batch "dispatch movetoworkspace $id ; dispatch togglespecialworkspace minimized"
      else
        cws=$(hyprctl activewindow -j | jq -r .workspace.name)
        case "$cws" in
          special:*) ;;
          *) hyprctl dispatch movetoworkspacesilent special:minimized ;;
        esac
      fi
    '';

  # Restore focused window from special:minimized to the active regular workspace.
  # monitors[].activeWorkspace reflects the underlying regular workspace even when a
  # special workspace is overlaid on top.
  hyprRestoreMinimized =
    pkgs:
    pkgs.writeShellScript "hypr-restore-minimized" ''
      id=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .activeWorkspace.id')
      hyprctl --batch "dispatch movetoworkspace $id ; dispatch togglespecialworkspace minimized"
    '';

  # Dismiss whichever special workspace is currently visible on the focused monitor.
  hyprDismissScratchpad =
    pkgs:
    pkgs.writeShellScript "hypr-dismiss-scratchpad" ''
      ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name' | sed 's/special://')
      [ -n "$ws" ] && hyprctl dispatch togglespecialworkspace "$ws"
    '';
in
{
  den.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland.settings.bind = [
          "$modifier, SPACE, exec, dms ipc launcher toggle"
          "$modifier SHIFT, RETURN, exec, ghostty"
          "$modifier, W, exec, zen-beta"
          "$modifier, T, exec, thunar"

          "$modifier, M,        layoutmsg, focusmaster"
          "$modifier, RETURN,   layoutmsg, swapwithmaster master"
          "$modifier  SHIFT, R, layoutmsg, rollnext"
          "$modifier ALT, R, layoutmsg, rollprev"

          "$modifier, C, killactive"
          "$modifier, F, fullscreen,"

          "$modifier SHIFT, F, togglefloating,"

          # WINDOW FOCUS AND MOVES
          "$modifier, X, focuscurrentorlast"
          "$modifier, U, focusurgentorlast"

          "$modifier, h, movefocus, l"
          "$modifier, l, movefocus, r"
          "$modifier, k, movefocus, u"
          "$modifier, j, movefocus, d"

          "$modifier SHIFT, h, movewindow, l"
          "$modifier SHIFT, l, movewindow, r"
          "$modifier SHIFT, k, movewindow, u"
          "$modifier SHIFT, j, movewindow, d"

          "$modifier CONTROL, l, resizeactive, 10 0"
          "$modifier CONTROL, h, resizeactive, -10 0"
          "$modifier CONTROL, k, resizeactive, 0 -10"
          "$modifier CONTROL, j, resizeactive, 0 10"

          "$modifier ALT, h, swapwindow, l"
          "$modifier ALT, l, swapwindow, r"
          "$modifier ALT, k, swapwindow, u"
          "$modifier ALT, j, swapwindow, d"

          # WORKSPACES
          "$modifier, Z, workspace, previous"

          "$modifier, 1, workspace, 1"
          "$modifier, 2, workspace, 2"
          "$modifier, 3, workspace, 3"
          "$modifier, 4, workspace, 4"
          "$modifier, 5, workspace, 5"

          "$modifier SHIFT, 1, movetoworkspace, 1"
          "$modifier SHIFT, 2, movetoworkspace, 2"
          "$modifier SHIFT, 3, movetoworkspace, 3"
          "$modifier SHIFT, 4, movetoworkspace, 4"
          "$modifier SHIFT, 5, movetoworkspace, 5"

          "$modifier CONTROL, 1, movetoworkspacesilent, 1"
          "$modifier CONTROL, 2, movetoworkspacesilent, 2"
          "$modifier CONTROL, 3, movetoworkspacesilent, 3"
          "$modifier CONTROL, 4, movetoworkspacesilent, 4"
          "$modifier CONTROL, 5, movetoworkspacesilent, 5"

          # Scratchpads — native special workspaces
          "$modifier, grave, togglespecialworkspace, term"
          "$modifier SHIFT, T, togglespecialworkspace, filemanager"
          "$modifier SHIFT, O, togglespecialworkspace, pw"
          "$modifier SHIFT, M, togglespecialworkspace, spotify"
          "$modifier SHIFT, S, togglespecialworkspace, slack"
          "$modifier SHIFT, E, togglespecialworkspace, ente"
          "$modifier, N, exec, ${hyprMinimizeRestore pkgs}"
          "$modifier SHIFT, N, exec, ${hyprRestoreMinimized pkgs}"
          "$modifier SHIFT, U, exec, ${hyprDismissScratchpad pkgs}"

          "ALT,Tab,cyclenext"

          # ── Media / brightness ──
          ", F1, exec, dms ipc audio mute"
          ", F2, exec, dms ipc audio decrement 5"
          ", F3, exec, dms ipc audio increment 5"
          ", F4, exec, dms ipc audio micmute"
          ", F5, exec, dms ipc brightness decrement 10 backlight:amdgpu_bl1"
          ", F6, exec, dms ipc brightness increment 10 backlight:amdgpu_bl1"

          # ── DMS toggles ──
          "$modifier SHIFT, P, exec, dms ipc powermenu toggle"
          "$modifier SHIFT, D, exec, dms ipc notifications toggleDoNotDisturb"
          "$modifier SHIFT, I, exec, dms ipc notepad toggle"
          "$modifier SHIFT, V, exec, dms ipc clipboard toggle"
          "$modifier SHIFT, B, exec, dms ipc notifications toggle"
          "$modifier SHIFT, G, exec, dms ipc control-center toggle"

          # ── Screenshot ──
          ", Print, exec, grim - | wl-copy"
          "CONTROL, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        ];
      };
  };
}
