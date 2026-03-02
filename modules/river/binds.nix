# River keybindings — translated from SwayFX equivalents.
# Merges into the river aspect via the collector pattern.
#
# Translation notes:
#   sway focus <dir>            -> river focus-view <dir>
#   sway move <dir>             -> river swap <dir>
#   sway kill                   -> river close
#   sway workspace N            -> river set-focused-tags $((1 << (N-1)))
#   sway move to workspace N    -> river set-view-tags $tag
#   sway floating toggle        -> river toggle-float
#   sway fullscreen             -> river toggle-fullscreen
#   persway stack-swap-main     -> river zoom
#   layout-switch (persway)     -> wideriver --layout-toggle
{ ... }:
{
  den.aspects.river = {
    homeManager =
      { ... }:
      {
        wayland.windowManager.river.extraConfig = ''
          # ── App launchers ──
          riverctl map normal Super Q spawn ghostty
          riverctl map normal Super W spawn zen-beta
          riverctl map normal Super Space spawn "dms ipc launcher toggle"

          # ── Window management ──
          riverctl map normal Super C close
          riverctl map normal Super F toggle-fullscreen
          riverctl map normal Super+Shift F toggle-float

          # ── Focus (vim keys) ──
          riverctl map normal Super H focus-view left
          riverctl map normal Super L focus-view right
          riverctl map normal Super K focus-view up
          riverctl map normal Super J focus-view down

          # ── Swap views (Shift+vim) ──
          riverctl map normal Super+Shift H swap left
          riverctl map normal Super+Shift L swap right
          riverctl map normal Super+Shift K swap up
          riverctl map normal Super+Shift J swap down

          # ── Resize (adjust wideriver master ratio) ──
          riverctl map -repeat normal Super+Control L spawn "riverctl send-layout-cmd wideriver '--ratio +0.05'"
          riverctl map -repeat normal Super+Control H spawn "riverctl send-layout-cmd wideriver '--ratio -0.05'"

          # ── Master count ──
          riverctl map normal Super+Control K spawn "riverctl send-layout-cmd wideriver '--count +1'"
          riverctl map normal Super+Control J spawn "riverctl send-layout-cmd wideriver '--count -1'"

          # ── Promote to master ──
          riverctl map normal Super Return zoom

          # ── Layout toggle (wide <-> monocle) ──
          riverctl map normal Super M spawn "riverctl send-layout-cmd wideriver '--layout-toggle'"

          # ── Tags (Workspaces 1-5) ──
          # Track current tag in state file for scratch-smart / scratch-toggle scripts.
          TAG_FILE="''${XDG_RUNTIME_DIR:-/tmp}/river-current-tag"
          SCRATCH_STATE="''${XDG_RUNTIME_DIR:-/tmp}/river-scratch-state"
          for i in $(seq 1 5); do
            tag=$((1 << (i - 1)))
            riverctl map normal Super "$i" spawn "echo $tag > $TAG_FILE && echo 0 > $SCRATCH_STATE && riverctl set-focused-tags $tag"
            riverctl map normal Super+Shift "$i" spawn "echo $tag > $TAG_FILE && echo 0 > $SCRATCH_STATE && riverctl set-view-tags $tag && riverctl set-focused-tags $tag"
            riverctl map normal Super+Control "$i" set-view-tags $tag
          done

          # ── Tag back-and-forth ──
          riverctl map normal Super Z focus-previous-tags

          # ── View all tags (Super+0) ──
          all_workspace_tags=$(( (1 << 5) - 1 ))
          riverctl map normal Super 0 set-focused-tags $all_workspace_tags
          riverctl map normal Super+Shift 0 set-view-tags $all_workspace_tags

          # ── Alt-Tab ──
          riverctl map normal Alt Tab focus-view next

          # ── Mouse bindings ──
          riverctl map-pointer normal Super BTN_LEFT move-view
          riverctl map-pointer normal Super BTN_RIGHT resize-view
          riverctl map-pointer normal Super BTN_MIDDLE toggle-float

          # ── Screenshot ──
          riverctl map normal None Print spawn "grim - | wl-copy"
          riverctl map normal Control Print spawn 'grim -g "$(slurp)" - | wl-copy'

          # ── Media / brightness (both normal and locked modes) ──
          for mode in normal locked; do
            riverctl map $mode None F1 spawn "dms ipc audio mute"
            riverctl map $mode None F2 spawn "dms ipc audio decrement 5"
            riverctl map $mode None F3 spawn "dms ipc audio increment 5"
            riverctl map $mode None F4 spawn "dms ipc audio micmute"
            riverctl map $mode None F5 spawn "dms ipc brightness decrement 10 backlight:amdgpu_bl1"
            riverctl map $mode None F6 spawn "dms ipc brightness increment 10 backlight:amdgpu_bl1"
          done

          # ── DMS toggles ──
          riverctl map normal Super+Shift P spawn "dms ipc powermenu toggle"
          riverctl map normal Super+Shift D spawn "dms ipc notifications toggleDoNotDisturb"
          riverctl map normal Super+Shift I spawn "dms ipc notepad toggle"
          riverctl map normal Super+Shift V spawn "dms ipc clipboard toggle"
          riverctl map normal Super+Shift B spawn "dms ipc notifications toggle"
          riverctl map normal Super+Shift G spawn "dms ipc control-center toggle"

          # ── Session ──
          riverctl map normal Super+Shift Q exit
        '';
      };
  };
}
