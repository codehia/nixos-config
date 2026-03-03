# MangoWC appearance — gaps, borders, colors, blur, shadows, animations.
# Merges into the mangowc aspect via the collector pattern.
{ ... }:
{
  den.aspects.mangowc = {
    homeManager =
      { ... }:
      {
        wayland.windowManager.mango.settings = ''
          # Gaps (matching Hyprland: gaps_in=5, gaps_out=7)
          gappih=7
          gappiv=7
          gappoh=7
          gappov=7

          # Borders (matching Hyprland: border_size=4, rounding=7)
          borderpx=4
          border_radius=7

          # Colors (Hyprland-style gradient approximation)
          focuscolor=0x33ccffee
          bordercolor=0x595959aa
          urgentcolor=0xff5555ff

          # Window effects (matching Hyprland decoration)
          blur=1
          blur_optimized=1
          blur_params_radius=5
          shadows=1
          focused_opacity=1.0
          unfocused_opacity=1.0

          # Animations
          animations=1
          animation_type_open=zoom
          animation_type_close=fade
          animation_duration_open=200
          animation_duration_close=150
          animation_duration_move=150

          # Bezier curves
          animation_curve_open=0.46,1.0,0.29,1
          animation_curve_move=0.46,1.0,0.29,1
          animation_curve_tag=0.46,1.0,0.29,1
          animation_curve_close=0.08,0.92,0,1
          animation_curve_focus=0.46,1.0,0.29,1
          animation_curve_opafadein=0.46,1.0,0.29,1
          animation_curve_opafadeout=0.5,0.5,0.5,0.5
        '';
      };
  };
}
