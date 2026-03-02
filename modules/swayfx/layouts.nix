# SwayFX layout management — master-slave via persway, center-master via custom script, spiral via persway.
# Merges into the swayfx aspect via the collector pattern.
#
# Mod+m cycles layouts: stack-main → center-master → spiral → …
# Mod+Return promotes focused window to master (mode-aware).
# Mod+Tab / Mod+Shift+Tab cycles focus through the stack (stack-main only).
# Mod+bracketright rotates the stack (stack-main only).
{ inputs, ... }:
{
  flake-file.inputs.persway.url = "github:johnae/persway";

  den.aspects.swayfx = {
    homeManager =
      {
        pkgs,
        lib,
        ...
      }:
      let
        system = pkgs.stdenv.hostPlatform.system;
        persway = inputs.persway.packages.${system}.default;

        # ── Center-master layout ──
        # Subcommands: apply, promote, watch, stop-watch
        # Arranges windows as: [left column] [MASTER 55%] [right column]
        # Master tracked via sway mark; watcher reapplies on window open/close.
        center-master = pkgs.writeShellApplication {
          name = "center-master";
          runtimeInputs = [
            pkgs.jq
            pkgs.sway
          ];
          text = ''
            MASTER_MARK="_cm_master"
            STATE_DIR="''${XDG_RUNTIME_DIR:-/tmp}/center-master"
            WATCHER_PID="$STATE_DIR/watcher.pid"
            MASTER_PCT=55

            mkdir -p "$STATE_DIR"

            cmd="''${1:-apply}"

            case "$cmd" in
              promote)
                # Mark focused window as the new master, then reapply layout
                focused=$(swaymsg -t get_tree | jq -r \
                  '.. | objects | select(.type == "con" and .focused and .pid > 0) | .id' \
                  | head -1)
                if [ -n "$focused" ] && [ "$focused" != "null" ]; then
                  swaymsg "[con_mark=$MASTER_MARK] mark --toggle $MASTER_MARK" 2>/dev/null || true
                  swaymsg "[con_id=$focused] mark --add $MASTER_MARK"
                fi
                exec "$0" apply
                ;;

              watch)
                # Event-driven watcher — reapplies on window open/close (not focus)
                echo $$ > "$WATCHER_PID"
                trap 'rm -f "$WATCHER_PID"' EXIT
                swaymsg -t subscribe '["window"]' | while read -r event; do
                  change=$(echo "$event" | jq -r '.change')
                  case "$change" in
                    new|close)
                      sleep 0.15
                      "$0" apply 2>/dev/null || true
                      ;;
                  esac
                done
                ;;

              stop-watch)
                if [ -f "$WATCHER_PID" ]; then
                  kill "$(cat "$WATCHER_PID")" 2>/dev/null || true
                  rm -f "$WATCHER_PID"
                fi
                ;;

              apply)
                # Prevent reentrant execution (our swaymsg calls trigger events)
                exec 9>"$STATE_DIR/apply.lock"
                flock -n 9 || exit 0

                tree=$(swaymsg -t get_tree)
                ws_json=$(echo "$tree" | jq \
                  '.. | objects | select(.type == "workspace" and .focused == true)' \
                  2>/dev/null) || exit 0
                ws_name=$(echo "$ws_json" | jq -r '.name')

                # Tiling windows only (recurse .nodes, skip .floating_nodes)
                mapfile -t all_ids < <(echo "$ws_json" | jq -r \
                  '[recurse(.nodes[]?) | select(.pid > 0)] | .[].id' 2>/dev/null)
                win_count=''${#all_ids[@]}

                if [ "$win_count" -le 1 ]; then
                  exit 0
                fi

                # ── Find master (marked window → focused → first) ──
                master_id=""
                for wid in "''${all_ids[@]}"; do
                  has_mark=$(echo "$ws_json" | jq -r --argjson id "$wid" --arg m "$MASTER_MARK" \
                    '[recurse(.nodes[]?) | select(.id == $id)] | .[0].marks // []
                     | if index($m) then "yes" else "no" end' 2>/dev/null)
                  if [ "$has_mark" = "yes" ]; then
                    master_id="$wid"
                    break
                  fi
                done
                if [ -z "$master_id" ]; then
                  master_id=$(echo "$ws_json" | jq -r \
                    '[recurse(.nodes[]?) | select(.pid > 0 and .focused)] | .[0].id' | head -1)
                fi
                if [ -z "$master_id" ] || [ "$master_id" = "null" ]; then
                  master_id="''${all_ids[0]}"
                fi
                swaymsg "[con_id=$master_id] mark --add $MASTER_MARK" 2>/dev/null || true

                # ── Split slaves into left/right columns (alternating) ──
                left=()
                right=()
                idx=0
                for wid in "''${all_ids[@]}"; do
                  if [ "$wid" != "$master_id" ]; then
                    if (( idx % 2 == 0 )); then
                      left+=("$wid")
                    else
                      right+=("$wid")
                    fi
                    idx=$((idx + 1))
                  fi
                done

                # ── Rearrange via temp workspace staging ──
                temp_ws="__cm_staging__"

                for wid in "''${all_ids[@]}"; do
                  swaymsg "[con_id=$wid] move to workspace $temp_ws" 2>/dev/null || true
                done
                swaymsg "workspace $ws_name" 2>/dev/null

                # Bring back: left[0], master, right[0] — creates flat H-split
                if [ ''${#left[@]} -gt 0 ]; then
                  swaymsg "[con_id=''${left[0]}] move to workspace current; \
                           [con_id=''${left[0]}] focus" 2>/dev/null
                fi

                swaymsg "[con_id=$master_id] move to workspace current; \
                         [con_id=$master_id] focus" 2>/dev/null

                if [ ''${#right[@]} -gt 0 ]; then
                  swaymsg "[con_id=''${right[0]}] move to workspace current" 2>/dev/null
                fi

                # Stack extra left windows vertically via move-to-mark
                if [ ''${#left[@]} -gt 1 ]; then
                  swaymsg "[con_id=''${left[0]}] mark _cm_left; \
                           [con_id=''${left[0]}] focus; splitv" 2>/dev/null
                  for ((i=1; i<''${#left[@]}; i++)); do
                    swaymsg "[con_id=''${left[$i]}] move to mark _cm_left" 2>/dev/null
                  done
                fi

                # Stack extra right windows vertically via move-to-mark
                if [ ''${#right[@]} -gt 1 ]; then
                  swaymsg "[con_id=''${right[0]}] mark _cm_right; \
                           [con_id=''${right[0]}] focus; splitv" 2>/dev/null
                  for ((i=1; i<''${#right[@]}; i++)); do
                    swaymsg "[con_id=''${right[$i]}] move to mark _cm_right" 2>/dev/null
                  done
                fi

                # Resize master to center proportion
                swaymsg "[con_id=$master_id] focus" 2>/dev/null
                swaymsg "[con_id=$master_id] resize set width $MASTER_PCT ppt" 2>/dev/null

                flock -u 9
                ;;
            esac
          '';
        };

        # ── Layout cycle: stack-main → center-master → spiral ──
        layout-switch = pkgs.writeShellApplication {
          name = "layout-switch";
          runtimeInputs = [
            persway
            center-master
            pkgs.libnotify
          ];
          text = ''
            STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/sway-layout-mode"
            current=$(cat "$STATE_FILE" 2>/dev/null || echo "stack-main")

            case "$current" in
              stack-main)
                persway change-layout manual
                center-master apply
                center-master watch &
                disown
                echo "center-master" > "$STATE_FILE"
                notify-send -t 2000 "Layout" "Center-master"
                ;;
              center-master)
                center-master stop-watch 2>/dev/null || true
                persway change-layout spiral
                echo "spiral" > "$STATE_FILE"
                notify-send -t 2000 "Layout" "Spiral"
                ;;
              spiral)
                persway change-layout stack-main --size 65
                echo "stack-main" > "$STATE_FILE"
                notify-send -t 2000 "Layout" "Master-stack"
                ;;
            esac
          '';
        };

        # ── Mode-aware promote: swap-main in stack-main, mark in center-master ──
        promote-master = pkgs.writeShellApplication {
          name = "promote-master";
          runtimeInputs = [
            persway
            center-master
          ];
          text = ''
            STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/sway-layout-mode"
            current=$(cat "$STATE_FILE" 2>/dev/null || echo "stack-main")

            case "$current" in
              stack-main) persway stack-swap-main ;;
              center-master) center-master promote ;;
              *) ;; # no-op for spiral
            esac
          '';
        };
      in
      {
        home.packages = [
          persway
          center-master
          layout-switch
          promote-master
        ];

        wayland.windowManager.sway.config.startup = [
          { command = "persway daemon -d stack-main"; }
        ];
      };
  };
}
