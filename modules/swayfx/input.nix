# SwayFX input settings — keyboard, touchpad.
# Merges into the swayfx aspect via the collector pattern.
_: {
  den.aspects.swayfx = {
    homeManager = _: {
      wayland.windowManager.sway.config = { };
    };
  };
}
