# SwayFX input settings — keyboard, touchpad.
# Merges into the swayfx aspect via the collector pattern.
{...}: {
  den.aspects.swayfx = {
    homeManager = {...}: {
      wayland.windowManager.sway.config = {
        input = {
          "type:keyboard" = {
            repeat_delay = "300";
            repeat_rate = "25";
            xkb_numlock = "disabled";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "disabled";
            dwt = "enabled";
            accel_profile = "adaptive";
            pointer_accel = "0.5";
          };
        };
      };
    };
  };
}
