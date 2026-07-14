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
  # Patch MangoWC to use 5 tags + a stash tag "S" instead of the default 9.
  # Tag count is compile-time (src/config/preset.h), so we override the source.
  # Tag 6 ("S") is the window stash — it has no view/tag number binds, so it is
  # only reachable through the stash keybindings below.
  # scenefx override: mango 0.14.4 needs scenefx-0.5, but mango's own flake.lock
  # pins 0.4.1 (and scenefx HEAD renamed its package attr to scenefx-git, so a
  # follows-override can't work). Drop this once upstream re-locks scenefx.
  patchMango =
    pkgs:
    (inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.override {
      scenefx = inputs.scenefx.packages.${pkgs.stdenv.hostPlatform.system}.scenefx-git;
    }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/config/preset.h \
            --replace-fail '"1", "2", "3", "4", "5", "6", "7", "8", "9"' \
                           '"1", "2", "3", "4", "5", "S"'
        '';
      });
in
{
  flake-file.inputs.mango = {
    url = "github:mangowm/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.scenefx = {
    url = "github:wlrfx/scenefx";
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
        mangoPkg = patchMango pkgs;

        # "Last workspace" toggle — mango has no prev-tag bind function (view,0
        # means "show ALL tags", not previous). With view_current_to_back=1,
        # dispatching view on the current tag jumps to the compositor's own
        # prevtag; mmsg supplies the current tag (single monitor assumed).
        # active_tags is [0] in overview mode, so the guard skips it there.
        viewPrevTag = pkgs.writeShellScript "mango-view-prev-tag" ''
          cur=$(${mangoPkg}/bin/mmsg get all-monitors \
            | ${pkgs.jq}/bin/jq -r '.monitors[0].active_tags[0] // 0')
          if [ "''${cur:-0}" -ge 1 ]; then
            exec ${mangoPkg}/bin/mmsg dispatch "view,$cur"
          fi
        '';

        # Window stash — tag 6 ("S") replaces mango's minimize/scratchpad pool,
        # which only shows one window at a time and restores floating-centered.
        # On a normal tag: send the focused window to the stash silently and
        # record its origin tag. On the stash tag: bounce back to the previous
        # tag (view_current_to_back) and bring the focused window along.
        # Origin records live in XDG_RUNTIME_DIR — client ids and the file both
        # reset with the session, so they stay in sync.
        stashToggle = pkgs.writeShellScript "mango-stash-toggle" ''
          mmsg=${mangoPkg}/bin/mmsg
          jq=${pkgs.jq}/bin/jq
          state="''${XDG_RUNTIME_DIR:-/tmp}/mango-stash-origins"

          mon=$($mmsg get all-monitors)
          tags=$(printf '%s' "$mon" | $jq -c '[.monitors[] | select(.active) | .active_tags[]]')
          cid=$(printf '%s' "$mon" | $jq -r '.monitors[] | select(.active) | .active_client.id // empty')
          [ -n "$cid" ] || exit 0

          if [ "$tags" = "[6]" ]; then
            # viewing the stash tag bounces to prevtag (view_current_to_back)
            $mmsg dispatch "view,6"
            cur=$($mmsg get all-monitors | $jq -r '.monitors[] | select(.active) | .active_tags[0] // 0')
            if [ "$cur" -lt 1 ] || [ "$cur" -gt 5 ]; then
              cur=1
              $mmsg dispatch "view,1"
            fi
            $mmsg dispatch "client,$cid,tagsilent,$cur"
            $mmsg dispatch "client,$cid,focusid"
            [ -f "$state" ] && sed -i "/^$cid /d" "$state"
          else
            client=$($mmsg get all-clients | $jq -c ".clients[] | select(.id == $cid)")
            [ -n "$client" ] || exit 0
            # named scratchpads carry their own toggle state — never stash them
            [ "$(printf '%s' "$client" | $jq '.is_namedscratchpad')" = "true" ] && exit 0
            origin=$(printf '%s' "$client" | $jq -r '.tags[0] // 0')
            if [ "$origin" -ge 1 ] && [ "$origin" -le 5 ]; then
              touch "$state"
              { grep -v "^$cid " "$state"; echo "$cid $origin"; } > "$state.new"
              mv "$state.new" "$state"
            fi
            $mmsg dispatch "client,$cid,tagsilent,6"
          fi
        '';

        # Restore the focused stashed window to the tag it was stashed from.
        # Falls back to stashToggle's restore-to-last when no origin record.
        restoreToOrigin = pkgs.writeShellScript "mango-restore-origin" ''
          mmsg=${mangoPkg}/bin/mmsg
          jq=${pkgs.jq}/bin/jq
          state="''${XDG_RUNTIME_DIR:-/tmp}/mango-stash-origins"

          cid=$($mmsg get all-monitors | $jq -r '.monitors[] | select(.active) | .active_client.id // empty')
          [ -n "$cid" ] || exit 0

          # only acts on stashed windows
          on_stash=$($mmsg get all-clients | $jq ".clients[] | select(.id == $cid) | .tags | contains([6])")
          [ "$on_stash" = "true" ] || exit 0

          origin=""
          [ -f "$state" ] && origin=$(grep "^$cid " "$state" | cut -d' ' -f2)
          if [ -n "$origin" ] && [ "$origin" -ge 1 ] && [ "$origin" -le 5 ]; then
            # tag moves the window, follows the view, and focuses it
            $mmsg dispatch "client,$cid,tag,$origin"
            sed -i "/^$cid /d" "$state"
          else
            exec ${stashToggle}
          fi
        '';

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
          package = mangoPkg;

          # Import all env vars into systemd so services (DMS, etc.)
          # get PATH, XDG_DATA_DIRS, and other session variables.
          systemd.variables = [ "--all" ];

          # Must be non-empty: the HM module only writes autostart.sh (and its
          # exec-once line) when this is set, and the systemd activation —
          # dbus env import + `systemctl --user start mango-session.target`,
          # which BindsTo graphical-session.target — lives inside that script.
          # Without it DMS and every graphical-session service never start.
          autostart_sh = ''
            # systemd/D-Bus activation is prepended by the HM module
          '';

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

            # Durations/curves mirror Hyprland's defaults (the smoothness target):
            # easeOutQuint 0.23,1,0.32,1; windowsIn ≈ 410ms, windows ≈ 480ms,
            # windowsOut ≈ 150ms, popin starts at 87% size. The previous
            # 150-200ms durations were too few frames and read as choppy.
            animations = 1;
            animation_type_open = "zoom";
            animation_type_close = "fade";
            animation_duration_open = 400;
            animation_duration_close = 150;
            animation_duration_move = 400;
            animation_duration_tag = 300;
            zoom_initial_ratio = 0.87;

            animation_curve_open = "0.23,1.0,0.32,1";
            animation_curve_move = "0.23,1.0,0.32,1";
            animation_curve_tag = "0.23,1.0,0.32,1";
            animation_curve_close = "0.08,0.92,0,1";
            animation_curve_focus = "0.23,1.0,0.32,1";
            animation_curve_opafadein = "0.23,1.0,0.32,1";
            animation_curve_opafadeout = "0.5,0.5,0.5,0.5";

            ### Layout, input, cursor, monitor
            default_mfact = 0.55;
            default_nmaster = 1;
            # center_tile: master spans the full width while it has no stack
            # windows (otherwise a lone window sits centered at mfact width)
            center_master_overspread = 1;

            repeat_delay = 300;
            repeat_rate = 25;
            numlockon = 0;
            sloppyfocus = 0;
            warpcursor = 0;

            # Mango's default (1) lets any xdg-activation request yank the view
            # back to the requesting client's tag — fullscreen VLC does this on
            # workspace switch, so leaving its tag looked impossible. 0 matches
            # Hyprland's focus_on_activate=false: the client is marked urgent
            # (border color) instead of stealing the view.
            focus_on_activate = 0;

            # Viewing the already-current tag jumps back to the previous one
            # (Hyprland's workspace_back_and_forth). Required by the SUPER,z
            # last-workspace script; side effect: SUPER,1-5 on the current
            # tag also goes back instead of being a no-op.
            view_current_to_back = 1;

            # Keep XWayland running even with no X11 apps open (reduces startup lag).
            # (the old `xwayland` toggle was removed upstream — XWayland is always built in)
            xwayland_persistence = 1;

            env = [ "XCURSOR_SIZE,32" ];

            # First matching rule wins — keep the specific rule above the wildcard.
            monitorrule = [
              # LG 34" ultrawide: run at its max mode (3440x1440@75.05);
              # model match survives connector/KVM changes
              "model:LG HDR WQHD,width:3440,height:1440,refresh:75.05,x:0,y:0,scale:1"
              "name:*,width:0,height:0,refresh:0,x:0,y:0,scale:1"
            ];

            # Centered-master layout (mango's closest to centertall) on the
            # ultrawide only; other monitors keep the default tile layout.
            tagrule = [
              "id:1,layout_name:center_tile,monitor_model:LG HDR WQHD"
              "id:2,layout_name:center_tile,monitor_model:LG HDR WQHD"
              "id:3,layout_name:center_tile,monitor_model:LG HDR WQHD"
              "id:4,layout_name:center_tile,monitor_model:LG HDR WQHD"
              "id:5,layout_name:center_tile,monitor_model:LG HDR WQHD"
            ];

            # Layouts SUPER,o cycles through (switch_layout); without this it
            # would cycle all 14 built-in layouts
            circle_layout = "tile,center_tile,monocle";

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

              # Window management
              "SUPER,c,killclient"
              "SUPER,f,togglefullscreen"
              "SUPER+SHIFT,f,togglefloating"
              "SUPER,x,focuslast"
              "SUPER,o,switch_layout"

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
              # z = last workspace via mmsg script (view,0 would show ALL tags)
              "SUPER,z,spawn,${viewPrevTag}"
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
              "SUPER,t,toggle_named_scratchpad,org.gnome.Nautilus,none,nautilus"
              "SUPER+SHIFT,o,toggle_named_scratchpad,1Password,none,1password --silent"
              "SUPER+SHIFT,m,toggle_named_scratchpad,Spotify,none,spotify"
              "SUPER+SHIFT,s,toggle_named_scratchpad,Slack,none,slack"
              "SUPER+SHIFT,e,toggle_named_scratchpad,io.ente.auth,none,enteauth"

              # Window stash (tag 6, "S") — see stashToggle above.
              # n stashes / restores to last focused workspace (context-aware);
              # SHIFT+n toggles the stash view; SHIFT+u restores to origin tag.
              "SUPER,n,spawn,${stashToggle}"
              "SUPER+SHIFT,n,view,6"
              "SUPER+SHIFT,u,spawn,${restoreToOrigin}"

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
