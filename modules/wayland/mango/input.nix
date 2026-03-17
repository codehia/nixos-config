# MangoWC input, layout, monitor, and misc settings.
# Merges into the mangowc aspect via the collector pattern.
_: {
  den.aspects.mangowc = {
    homeManager = _: {
      wayland.windowManager.mango.settings = ''
        # Layout — master-stack like Hyprland
        default_mfact=0.62
        default_nmaster=1

        # Input
        repeat_delay=300
        repeat_rate=25
        numlockon=0
        sloppyfocus=0
        warpcursor=0

        # Misc
        xwayland=1

        # Cursor
        env=XCURSOR_SIZE,32

        # Monitor (auto-detect)
        monitorrule=name:*,width:0,height:0,refresh:0,x:0,y:0,scale:1
      '';
    };
  };
}
