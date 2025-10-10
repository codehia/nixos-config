_: {
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$modifier, P, exec, rofi -show drun"
      "$modifier, Q, exec, ghostty"
      "$modifier, W, exec, zen"
      "$modifier, T, exec, thunar"

      "$modifier, M,        layoutmsg, focusmaster"
      "$modifier, RETURN,   layoutmsg, swapwithmaster master"
      "$modifier  SHIFT, R, layoutmsg, rollnext"
      "$modifier  SHIFT, P, layoutmsg, rollprev"

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

      # PYPR
      "$modifier SHIFT, K, exec, pypr toggle term"
      "$modifier SHIFT, T, exec, pypr toggle filemanager"
      "$modifier SHIFT, N, togglespecialworkspace, minimized"
      "$modifier, N, exec, pypr toggle_special minimized"

      "ALT,Tab,cyclenext"
    ];
  };
}
