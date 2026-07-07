# MangoWC compositor — lightweight Wayland compositor based on dwl.
# System half (binary + session entry via programs.mango) lives in den.aspects.wm-sessions;
# the HM half (generated ~/.config/mango/config.conf) reaches every user via
# den.aspects.wm-configs (den.default).
#
# NOTE: unlike the other WM aspects, all settings live in this single file — the HM
# module's structured `settings` option is a oneOf type that permits only ONE
# definition, so the old multi-file collector split cannot merge it.
{ den, inputs, ... }:
let
  # Patch MangoWC to use 5 tags instead of the default 9.
  # Tag count is compile-time (src/config/preset.h), so we override the source.
  patchMango =
    pkgs:
    inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/config/preset.h \
          --replace-fail '"1", "2", "3", "4", "5", "6", "7", "8", "9"' \
                         '"1", "2", "3", "4", "5"'
      '';
    });
in
{
  flake-file.inputs.mango = {
    url = "github:mangowm/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.wm-configs.includes = [ den.aspects.mangowc ];

  den.aspects.wm-sessions = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.mango.nixosModules.mango ];
        programs.mango = {
          enable = true;
          package = patchMango pkgs;
        };
      };
  };

  den.aspects.mangowc = {
    homeManager =
      { pkgs, ... }:
      let
        # Screenshots use grim/slurp per mango's own docs — grimblast (hyprctl) and
        # grimshot (swaymsg) only work under their respective compositors.
        screenshotFull = pkgs.writeShellScript "mango-screenshot-full" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          ${pkgs.grim}/bin/grim - \
            | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" \
            | ${pkgs.wl-clipboard}/bin/wl-copy
        '';

        screenshotArea = pkgs.writeShellScript "mango-screenshot-area" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - \
            | tee "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png" \
            | ${pkgs.wl-clipboard}/bin/wl-copy
        '';

        screenshotAnnotate = pkgs.writeShellScript "mango-screenshot-annotate" ''
          mkdir -p "$HOME/Pictures/Screenshots"
          FILE=$(mktemp /tmp/screenshot-XXXXXX.png)
          ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE" \
            && ${pkgs.satty}/bin/satty --filename "$FILE" \
              --output-filename "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          rm -f "$FILE"
        '';
      in
      {
        imports = [ inputs.mango.hmModules.mango ];

        home.packages = with pkgs; [
          grim
          slurp
          satty
          wl-clipboard
        ];

        wayland.windowManager.mango = {
          enable = true;
          package = patchMango pkgs;

          # Import all env vars into systemd so services (DMS, etc.)
          # get PATH, XDG_DATA_DIRS, and other session variables.
          systemd.variables = [ "--all" ];

          settings = {
            ### Appearance — gaps, borders, colors, blur, shadows, animations
            ### (matching the Hyprland look)
            gappih = 7;
            gappiv = 7;
            gappoh = 7;
            gappov = 7;

            borderpx = 4;
            border_radius = 7;

            focuscolor = "0x33ccffee";
            bordercolor = "0x595959aa";
            urgentcolor = "0xff5555ff";

            blur = 1;
            blur_optimized = 1;
            blur_params_radius = 5;
            shadows = 1;
            focused_opacity = 1.0;
            unfocused_opacity = 1.0;

            animations = 1;
            animation_type_open = "zoom";
            animation_type_close = "fade";
            animation_duration_open = 200;
            animation_duration_close = 150;
            animation_duration_move = 150;

            animation_curve_open = "0.46,1.0,0.29,1";
            animation_curve_move = "0.46,1.0,0.29,1";
            animation_curve_tag = "0.46,1.0,0.29,1";
            animation_curve_close = "0.08,0.92,0,1";
            animation_curve_focus = "0.46,1.0,0.29,1";
            animation_curve_opafadein = "0.46,1.0,0.29,1";
            animation_curve_opafadeout = "0.5,0.5,0.5,0.5";

            ### Layout, input, cursor, monitor
            default_mfact = 0.62;
            default_nmaster = 1;

            repeat_delay = 300;
            repeat_rate = 25;
            numlockon = 0;
            sloppyfocus = 0;
            warpcursor = 0;

            # Keep XWayland running even with no X11 apps open (reduces startup lag).
            # (the old `xwayland` toggle was removed upstream — XWayland is always built in)
            xwayland_persistence = 1;

            env = [ "XCURSOR_SIZE,32" ];

            monitorrule = [ "name:*,width:0,height:0,refresh:0,x:0,y:0,scale:1" ];

            ### Named scratchpads — apps ONLY exist as scratchpads; the binds below
            ### lazy-spawn them on first use (like Hyprland's on-created-empty).
            scratchpad_width_ratio = 0.7;
            scratchpad_height_ratio = 0.7;

            windowrule = [
              "isnamedscratchpad:1,appid:kitty-term"
              "isnamedscratchpad:1,appid:org.gnome.Nautilus"
              "isnamedscratchpad:1,appid:1Password"
              "isnamedscratchpad:1,appid:Spotify"
              "isnamedscratchpad:1,appid:Slack"
              "isnamedscratchpad:1,appid:io.ente.auth"
            ];

            ### Keybindings — canonical Hyprland scheme wherever mango has an equivalent
            bind = [
              # Application launchers
              "SUPER,SPACE,spawn,dms ipc launcher toggle"
              "SUPER+SHIFT,Return,spawn,ghostty"
              "SUPER,w,spawn,zen-beta"
              "SUPER,t,spawn,nautilus"

              # Window management
              "SUPER,c,killclient"
              "SUPER,f,togglemaximizescreen"
              "SUPER+SHIFT,f,togglefloating"
              "SUPER,x,focuslast"

              # Master layout — zoom = swap with master (mango has no focus-master)
              "SUPER,Return,zoom"
              "SUPER+ALT,i,incnmaster,+1"
              "SUPER+ALT,d,incnmaster,-1"

              # Vim-style focus navigation
              "SUPER,h,focusdir,left"
              "SUPER,l,focusdir,right"
              "SUPER,k,focusdir,up"
              "SUPER,j,focusdir,down"

              # Vim-style window moving (swap with neighbor)
              "SUPER+SHIFT,h,exchange_client,left"
              "SUPER+SHIFT,l,exchange_client,right"
              "SUPER+SHIFT,k,exchange_client,up"
              "SUPER+SHIFT,j,exchange_client,down"

              # Resize master factor
              "SUPER+CTRL,l,setmfact,+0.02"
              "SUPER+CTRL,h,setmfact,-0.02"

              # Tag navigation (tags are dwm-style workspaces)
              "SUPER,z,viewtoleft"
              "SUPER,1,view,1"
              "SUPER,2,view,2"
              "SUPER,3,view,3"
              "SUPER,4,view,4"
              "SUPER,5,view,5"

              # Move window to tag
              "SUPER+SHIFT,1,tag,1"
              "SUPER+SHIFT,2,tag,2"
              "SUPER+SHIFT,3,tag,3"
              "SUPER+SHIFT,4,tag,4"
              "SUPER+SHIFT,5,tag,5"

              # Move window to tag silently (stay on current)
              "SUPER+CTRL,1,tagsilent,1"
              "SUPER+CTRL,2,tagsilent,2"
              "SUPER+CTRL,3,tagsilent,3"
              "SUPER+CTRL,4,tagsilent,4"
              "SUPER+CTRL,5,tagsilent,5"

              # Named scratchpads — canonical Hyprland keys
              "SUPER,grave,toggle_named_scratchpad,kitty-term,none,kitty --class kitty-term"
              "SUPER+SHIFT,t,toggle_named_scratchpad,org.gnome.Nautilus,none,nautilus"
              "SUPER+SHIFT,o,toggle_named_scratchpad,1Password,none,1password --silent"
              "SUPER+SHIFT,m,toggle_named_scratchpad,Spotify,none,spotify"
              "SUPER+SHIFT,s,toggle_named_scratchpad,Slack,none,slack"
              "SUPER+SHIFT,e,toggle_named_scratchpad,io.ente.auth,none,enteauth"

              # Minimized pool (≈ Hyprland special:minimized)
              "SUPER,n,minimized"
              "SUPER+SHIFT,n,toggle_scratchpad"
              "SUPER+SHIFT,u,restore_minimized"

              # Alt-Tab cycling
              "ALT,Tab,focusstack,next"

              # Media / brightness (DMS)
              "NONE,F1,spawn,dms ipc audio mute"
              "NONE,F2,spawn,dms ipc audio decrement 5"
              "NONE,F3,spawn,dms ipc audio increment 5"
              "NONE,F4,spawn,dms ipc audio micmute"
              "NONE,F5,spawn,dms ipc brightness decrement 10 backlight:amdgpu_bl1"
              "NONE,F6,spawn,dms ipc brightness increment 10 backlight:amdgpu_bl1"

              # DMS toggles
              "SUPER+SHIFT,p,spawn,dms ipc powermenu toggle"
              "SUPER+SHIFT,d,spawn,dms ipc notifications toggleDoNotDisturb"
              "SUPER+SHIFT,i,spawn,dms ipc notepad toggle"
              "SUPER+SHIFT,v,spawn,dms ipc clipboard toggle"
              "SUPER+SHIFT,b,spawn,dms ipc notifications toggle"
              "SUPER+SHIFT,g,spawn,dms ipc control-center toggle"

              # Screenshots
              "SUPER,p,spawn,${screenshotFull}"
              "SUPER+CTRL,p,spawn,${screenshotArea}"
              "SUPER+ALT,p,spawn,${screenshotAnnotate}"

              # Session
              "SUPER+SHIFT,c,reload_config"
              "SUPER+SHIFT,q,quit"
            ];

            mousebind = [
              "SUPER,btn_left,moveresize,move"
              "SUPER,btn_right,moveresize,resize"
            ];
          };
        };
      };
  };
}
