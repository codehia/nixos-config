# River tag-based scratchpads — per-app toggleable overlays using high tag bits.
# Merges into the river aspect via the collector pattern.
#
# Tag layout:
#   Bits 0-4:   Workspaces 1-5 (values: 1, 2, 4, 8, 16)
#   Bit 20:     Generic scratchpad
#   Bit 21:     kitty-dropterm
#   Bit 22:     1password
#   Bit 23:     Spotify
#   Bit 24:     Slack
#   Bit 25:     Ente Auth
#   Bit 26:     Thunar
#
# Generic scratchpad uses scratch-smart / scratch-toggle scripts (matching SwayFX UX):
#   Super+N       — scratch-smart: minimize focused window to scratch, or restore if on scratch
#   Super+Shift+N — scratch-toggle: switch to scratch "workspace" view, or back to previous
#
# Per-app scratchpads use toggle-focused-tags to overlay on current workspace (always float).
{ ... }:
{
  den.aspects.river = {
    homeManager =
      { pkgs, ... }:
      let
        # scratch-smart: minimize focused window to scratch tag, or restore if viewing scratch.
        # Mirrors SwayFX scratch-smart behavior.
        scratch-smart = pkgs.writeShellScriptBin "scratch-smart" ''
          STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/river-scratch-state"
          TAG_FILE="''${XDG_RUNTIME_DIR:-/tmp}/river-current-tag"
          SCRATCH_TAG=$((1 << 20))

          in_scratch=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

          if [ "$in_scratch" = "1" ]; then
            # Viewing scratch: restore focused window to previous workspace
            prev_tag=$(cat "$TAG_FILE" 2>/dev/null || echo 1)
            riverctl set-view-tags "$prev_tag"
          else
            # On workspace: send focused window to scratch (minimize)
            riverctl set-view-tags $SCRATCH_TAG
          fi
        '';

        # scratch-toggle: switch between current workspace and scratch "workspace" view.
        # Mirrors SwayFX scratch-toggle behavior.
        scratch-toggle = pkgs.writeShellScriptBin "scratch-toggle" ''
          STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/river-scratch-state"
          TAG_FILE="''${XDG_RUNTIME_DIR:-/tmp}/river-current-tag"
          SCRATCH_TAG=$((1 << 20))

          in_scratch=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

          if [ "$in_scratch" = "1" ]; then
            # On scratch: go back to previous workspace
            prev_tag=$(cat "$TAG_FILE" 2>/dev/null || echo 1)
            riverctl set-focused-tags "$prev_tag"
            echo 0 > "$STATE_FILE"
          else
            # On workspace: switch to scratch view
            riverctl set-focused-tags $SCRATCH_TAG
            echo 1 > "$STATE_FILE"
          fi
        '';
      in
      {
        home.packages = [
          scratch-smart
          scratch-toggle
        ];

        wayland.windowManager.river.extraConfig = ''
          # ── Scratchpad tag definitions ──
          scratch_tag=$((1 << 20))
          kitty_tag=$((1 << 21))
          onepass_tag=$((1 << 22))
          spotify_tag=$((1 << 23))
          slack_tag=$((1 << 24))
          ente_tag=$((1 << 25))
          thunar_tag=$((1 << 26))

          all_scratch=$(( scratch_tag | kitty_tag | onepass_tag | spotify_tag | slack_tag | ente_tag | thunar_tag ))

          # ── Prevent new windows from spawning on scratchpad tags ──
          all_tags=$(( (1 << 32) - 1 ))
          riverctl spawn-tagmask $(( all_tags ^ all_scratch ))

          # ── Window rules: route apps to scratch tags + float ──
          riverctl rule-add -app-id "kitty-dropterm" tags $kitty_tag
          riverctl rule-add -app-id "kitty-dropterm" float

          riverctl rule-add -app-id "1password" tags $onepass_tag
          riverctl rule-add -app-id "1password" float

          riverctl rule-add -app-id "Spotify" tags $spotify_tag
          riverctl rule-add -app-id "Spotify" float

          riverctl rule-add -app-id "Slack" tags $slack_tag
          riverctl rule-add -app-id "Slack" float

          riverctl rule-add -app-id "io.ente.auth" tags $ente_tag
          riverctl rule-add -app-id "io.ente.auth" float

          riverctl rule-add -app-id "thunar" tags $thunar_tag
          riverctl rule-add -app-id "thunar" float

          # ── Generic scratchpad keybindings ──
          # Super+N: minimize focused window to scratch, or restore if viewing scratch
          riverctl map normal Super N spawn scratch-smart
          # Super+Shift+N: toggle scratch "workspace" view
          riverctl map normal Super+Shift N spawn scratch-toggle

          # ── Per-app scratchpad toggles (overlay on current workspace, always float) ──
          riverctl map normal Super Grave toggle-focused-tags $kitty_tag
          riverctl map normal Super+Shift O toggle-focused-tags $onepass_tag
          riverctl map normal Super+Shift M toggle-focused-tags $spotify_tag
          riverctl map normal Super+Shift S toggle-focused-tags $slack_tag
          riverctl map normal Super E toggle-focused-tags $ente_tag
          riverctl map normal Super T toggle-focused-tags $thunar_tag
        '';
      };
  };
}
