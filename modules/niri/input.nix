# Niri input and monitor settings.
# Collector pattern: merged into den.aspects.niri by den.
_: {
  den.aspects.niri = {
    homeManager = _: {
      programs.niri.settings = {
        input = {
          keyboard = {
            repeat-delay = 300;
            repeat-rate = 25;
            xkb = { };
          };
          touchpad = {
            tap = true;
            natural-scroll = false;
            dwt = true;
            accel-speed = 0.5;
          };
          focus-follows-mouse.enable = false;
          warp-mouse-to-focus.enable = false;
        };
      };
    };
  };
}
