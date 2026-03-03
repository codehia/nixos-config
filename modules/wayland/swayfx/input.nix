# SwayFX input settings — keyboard, touchpad.
# Merges into the swayfx aspect via the collector pattern.
{ ... }:
{
  den.aspects.swayfx = {
    homeManager =
      { ... }:
      {
        wayland.windowManager.sway.config = { };
      };
  };
}
