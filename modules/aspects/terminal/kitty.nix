{
  den.aspects.terminal = {
    homeManager.programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      font = {
        name = "Iosevka Nerd Font Mono";
        size = 14;
      };
      shellIntegration = {
        enableFishIntegration = true;
        mode = "no-rc no-cursor";
      };
      extraConfig = ''
        cursor #cccccc
        cursor_shape block
        cursor_beam_thickness 1.5
        cursor_blink_interval -1
        cursor_stop_blinking_after 15.0
        window_padding_width 4
      '';
    };
  };
}
