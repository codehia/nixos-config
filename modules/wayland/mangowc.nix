# MangoWC compositor — lightweight Wayland compositor based on dwl.
# Configured to mirror Hyprland keybindings and appearance.
{inputs, ...}: {
  flake-file.inputs.mango = {
    url = "github:DreamMaoMao/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.mangowc = {
    nixos = {pkgs, ...}: {
      imports = [inputs.mango.nixosModules.mango];
      programs.mango = {
        enable = true;
        package = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango;
      };
    };

    homeManager = {pkgs, ...}: {
      imports = [inputs.mango.hmModules.mango];

      home.packages = with pkgs; [
        grim
        slurp
        wl-clipboard
        swappy
      ];

      wayland.windowManager.mango = {
        enable = true;

        settings = ''
          # ============================================
          # APPEARANCE - Mirroring Hyprland theme
          # ============================================

          # Gaps (matching Hyprland: gaps_in=5, gaps_out=7)
          gappih=5
          gappiv=5
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

          # ============================================
          # ANIMATIONS
          # ============================================
          animations=1
          animation_type_open=zoom
          animation_type_close=fade
          animation_duration_open=200
          animation_duration_close=150
          animation_duration_move=150

          # ============================================
          # LAYOUT - Master-stack like Hyprland
          # ============================================
          default_mfact=0.62
          default_nmaster=1

          # ============================================
          # INPUT - Matching Hyprland settings
          # ============================================
          repeat_delay=300
          repeat_rate=25
          numlockon=0
          sloppyfocus=0
          warpcursor=0

          # ============================================
          # MISC
          # ============================================
          xwayland=1

          # ============================================
          # CURSOR
          # ============================================
          env=XCURSOR_SIZE,32

          # ============================================
          # MONITOR (auto-detect)
          # ============================================
          monitorrule=name:*,width:0,height:0,refresh:0,x:0,y:0,scale:1

          # ============================================
          # KEYBINDINGS - Mirroring Hyprland
          # ============================================

          # Application launchers
          bind=SUPER,p,spawn,rofi -show drun
          bind=SUPER,q,spawn,ghostty
          bind=SUPER,w,spawn,zen
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
          bind=SUPER,n,toggle_scratchpad
          bind=SUPER+SHIFT,n,minimized

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

        autostart_sh = ''
          # Autostart applications (matching Hyprland exec-once)
          1password --silent &
          spotify &
          mullvad-gui &
          enteauth &
        '';
      };
    };
  };
}
