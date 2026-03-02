# River input settings — keyboard, touchpad, focus behavior.
# Merges into the river aspect via the collector pattern.
{ ... }:
{
  den.aspects.river = {
    homeManager =
      { ... }:
      {
        wayland.windowManager.river = {
          settings = {
            set-repeat = "25 300";
            focus-follows-cursor = "disabled";
            set-cursor-warp = "disabled";
          };

          extraConfig = ''
            # ── Touchpad settings ──
            riverctl input "*" tap enabled
            riverctl input "*" natural-scroll disabled
            riverctl input "*" disable-while-typing enabled
            riverctl input "*" scroll-factor 0.8
          '';
        };
      };
  };
}
