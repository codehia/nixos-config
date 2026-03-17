# MangoWC keybindings — merges into the mangowc aspect via the collector pattern.
# den.aspects.mangowc is also defined in mangowc.nix; den merges both definitions.
_: {
  den.aspects.mangowc = {
    homeManager = _: {
      wayland.windowManager.mango.settings = ''
        # Application launchers
        bind=SUPER,p,spawn,rofi -show drun
        bind=SUPER,q,spawn,ghostty
        bind=SUPER,w,spawn,zen-beta
        bind=SUPER,t,spawn,thunar

        # Window management
        bind=SUPER,c,killclient
        bind=SUPER,f,togglemaximizescreen
        bind=SUPER+SHIFT,f,togglefloating

        # Master layout controls
        bind=SUPER,m,zoom
        bind=SUPER,Return,zoom
        bind=SUPER+SHIFT,r,incnmaster,+1
        bind=SUPER+SHIFT,p,incnmaster,-1

        # Vim-style focus navigation
        bind=SUPER,h,focusdir,left
        bind=SUPER,l,focusdir,right
        bind=SUPER,k,focusdir,up
        bind=SUPER,j,focusdir,down

        # Vim-style window moving
        bind=SUPER+SHIFT,h,movedir,left
        bind=SUPER+SHIFT,l,movedir,right
        bind=SUPER+SHIFT,k,movedir,up
        bind=SUPER+SHIFT,j,movedir,down

        # Resize
        bind=SUPER+CTRL,l,setmfact,+0.02
        bind=SUPER+CTRL,h,setmfact,-0.02

        # Tag/workspace navigation (MangoWC uses tags like dwm)
        bind=SUPER,z,viewtoleft
        bind=SUPER,1,view,1
        bind=SUPER,2,view,2
        bind=SUPER,3,view,3
        bind=SUPER,4,view,4
        bind=SUPER,5,view,5

        # Move window to tag
        bind=SUPER+SHIFT,1,tag,1
        bind=SUPER+SHIFT,2,tag,2
        bind=SUPER+SHIFT,3,tag,3
        bind=SUPER+SHIFT,4,tag,4
        bind=SUPER+SHIFT,5,tag,5

        # Move window to tag silently (stay on current)
        bind=SUPER+CTRL,1,toggletag,1
        bind=SUPER+CTRL,2,toggletag,2
        bind=SUPER+CTRL,3,toggletag,3
        bind=SUPER+CTRL,4,toggletag,4
        bind=SUPER+CTRL,5,toggletag,5

        # Scratchpad (like Hyprland special workspace)
        bind=SUPER,n,minimized
        bind=SUPER+SHIFT,n,restore_minimized
        bind=SUPER,i,toggle_scratchpad

        # Alt-Tab cycling
        bind=ALT,Tab,focusstack,next

        # Mouse bindings
        mousebind=SUPER,btn_left,moveresize,move
        mousebind=SUPER,btn_right,moveresize,resize

        # Reload config
        bind=SUPER+SHIFT,c,reload_config

        # Exit MangoWC
        bind=SUPER+SHIFT,q,quit
      '';
    };
  };
}
