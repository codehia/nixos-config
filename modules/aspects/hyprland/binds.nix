# Hyprland keybindings — merges into the hyprland aspect via the collector pattern.
# den.aspects.hyprland is also defined in hyprland.nix; den merges both definitions.
{
  den.aspects.hyprland = {
    homeManager =
      { lib, pkgs, ... }:
      let
        hyprMods = {
          none = "";
          super = "$modifier";
          "super+shift" = "$modifier SHIFT";
        };
        dmsBinds = map (b: "${hyprMods.${b.mods}}, ${lib.toUpper b.key}, exec, ${b.cmd}") (
          import ../wayland/_dms-binds.nix
        );

        workspaceBinds = lib.concatMap (
          n:
          let
            s = toString n;
          in
          [
            "$modifier, ${s}, workspace, ${s}"
            "$modifier SHIFT, ${s}, movetoworkspace, ${s}"
            "$modifier CONTROL, ${s}, movetoworkspacesilent, ${s}"
          ]
        ) (lib.range 1 5);

        # Minimize/restore toggle: if special:minimized is visible restore focused window,
        # otherwise dismiss any other visible scratchpad and send current window to special:minimized.
        hyprMinimizeRestore = pkgs.writeShellScript "hypr-minimize-restore" ''
          current=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name' | sed 's/special://')
          if [ "$current" = "minimized" ]; then
            id=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .activeWorkspace.id')
            hyprctl --batch "dispatch movetoworkspace $id ; dispatch togglespecialworkspace minimized"
          else
            [ -n "$current" ] && hyprctl dispatch togglespecialworkspace "$current"
            cws=$(hyprctl activewindow -j | jq -r .workspace.name)
            case "$cws" in
              special:*) ;;
              *) hyprctl dispatch movetoworkspacesilent special:minimized ;;
            esac
          fi
        '';

        # Dismiss whichever special workspace is currently visible on the focused monitor.
        hyprDismissScratchpad = pkgs.writeShellScript "hypr-dismiss-scratchpad" ''
          ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name' | sed 's/special://')
          [ -n "$ws" ] && hyprctl dispatch togglespecialworkspace "$ws"
        '';

        # Toggle a named scratchpad, hiding any other visible special workspace first.
        hyprToggleScratchpad = pkgs.writeShellScript "hypr-toggle-scratchpad" ''
          target="$1"
          current=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name' | sed 's/special://')
          if [ "$current" = "$target" ]; then
            hyprctl dispatch togglespecialworkspace "$target"
          elif [ -n "$current" ]; then
            hyprctl --batch "dispatch togglespecialworkspace $current ; dispatch togglespecialworkspace $target"
          else
            hyprctl dispatch togglespecialworkspace "$target"
          fi
        '';

        screenshotAnnotate = pkgs.writeShellScript "screenshot-annotate" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          FILE=$(mktemp /tmp/screenshot-XXXXXX.png)
          grimblast --freeze save area "$FILE" && satty --filename "$FILE" --output-filename "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          rm -f "$FILE"
        '';
      in
      {
        wayland.windowManager.hyprland.settings.bind =
          dmsBinds
          ++ workspaceBinds
          ++ [
            "$modifier SHIFT, RETURN, exec, ghostty"
            "$modifier, W, exec, default-browser"

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
            # 1-5: workspaceBinds above

            # Scratchpads — native special workspaces (only one visible at a time)
            "$modifier, grave, exec, ${hyprToggleScratchpad} term"
            "$modifier, T, exec, ${hyprToggleScratchpad} filemanager"
            "$modifier SHIFT, O, exec, ${hyprToggleScratchpad} pw"
            "$modifier SHIFT, S, exec, ${hyprToggleScratchpad} slack"
            "$modifier SHIFT, E, exec, ${hyprToggleScratchpad} ente"
            "$modifier, N, exec, ${hyprMinimizeRestore}"
            "$modifier SHIFT, N, exec, ${hyprToggleScratchpad} minimized"
            "$modifier SHIFT, U, exec, ${hyprDismissScratchpad}"

            "ALT,Tab,cyclenext"

            # Media/brightness + DMS toggles: dmsBinds (wayland/_dms-binds.nix)

            # ── Screenshot ──
            "$modifier, P, exec, grimblast --notify copysave screen"
            "$modifier CONTROL, P, exec, grimblast --notify copysave area"
            "$modifier ALT, P, exec, ${screenshotAnnotate}"
          ];

        # Mouse drag move/resize — parity with mango's SUPER+LMB/RMB mousebinds.
        wayland.windowManager.hyprland.settings.bindm = [
          "$modifier, mouse:272, movewindow"
          "$modifier, mouse:273, resizewindow"
        ];
      };
  };
}
