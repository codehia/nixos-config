# sway-scratch — per-app named scratchpad toggler for Sway.
# Also provides scratch-smart / scratch-toggle for a tabbed __scratch__ workspace.
# Merges into the swayfx aspect via the collector pattern.
{ inputs, ... }:
{
  flake-file.inputs.sway-scratch = {
    url = "github:aokellermann/sway-scratch";
    flake = false;
  };

  den.aspects.swayfx = {
    homeManager =
      { pkgs, ... }:
      let
        sway-scratch = pkgs.rustPlatform.buildRustPackage {
          pname = "sway-scratch";
          version = "0.2.1";
          src = inputs.sway-scratch;
          cargoLock.lockFile = "${inputs.sway-scratch}/Cargo.lock";
          meta = {
            description = "Named scratchpad manager for Sway";
            homepage = "https://github.com/aokellermann/sway-scratch";
          };
        };

        # Mod+N: minimize focused window to __scratch__ workspace,
        #        or restore focused window back if already on __scratch__.
        scratch-smart = pkgs.writeShellScriptBin "scratch-smart" ''
          CURRENT=$(swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
          if [ "$CURRENT" = "__scratch__" ]; then
            swaymsg "move container to workspace back_and_forth; workspace back_and_forth"
          else
            swaymsg "move container to workspace __scratch__"
          fi
        '';

        # Mod+Shift+N: toggle the __scratch__ workspace (tabbed layout).
        scratch-toggle = pkgs.writeShellScriptBin "scratch-toggle" ''
          CURRENT=$(swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
          if [ "$CURRENT" = "__scratch__" ]; then
            swaymsg "workspace back_and_forth"
          else
            swaymsg "workspace __scratch__; layout tabbed"
          fi
        '';
      in
      {
        home.packages = [
          sway-scratch
          scratch-smart
          scratch-toggle
        ];

        wayland.windowManager.sway.config.floating.criteria = [
          { app_id = "kitty-dropterm"; }
          { app_id = "1password"; }
          { class = "Spotify"; }
          { class = "Slack"; }
          { app_id = "io.ente.auth"; }
          { app_id = "org.gnome.Nautilus"; }
        ];

        # Auto-scratchpad apps that are pre-launched at startup so they start hidden.
        # sway-scratch can then find them in the scratchpad and show/hide on demand.
        # Only applies to startup apps — on-demand apps (kitty-dropterm, nautilus, slack)
        # are NOT listed here so their first sway-scratch invocation shows them directly.
        wayland.windowManager.sway.config.window.commands = [
          {
            criteria.app_id = "1password";
            command = "move scratchpad";
          }
          {
            criteria.class = "Spotify";
            command = "move scratchpad";
          }
          {
            criteria.app_id = "io.ente.auth";
            command = "move scratchpad";
          }
        ];
      };
  };
}
