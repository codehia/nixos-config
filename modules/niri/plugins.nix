# Niri plugins: niri-scratchpad (per-app scratchpads) and nfsm (fullscreen position fix).
# Collector pattern: merged into den.aspects.niri by den.
#
# niri-scratchpad: CLI (nscratch) — per-app scratchpads on dedicated "scratch" workspace.
#   Apps ONLY exist in the scratchpad — even if launched from rofi, window rules redirect
#   them to the "scratch" workspace. nscratch toggles them to/from the current workspace.
#   If the app isn't running, nscratch spawns it via the -s flag.
#
# Nirius: daemon (niriusd) + CLI (nirius) — generic minimize, focus-or-spawn, follow-mode.
# nfsm: daemon (nfsm) + client (nfsm-cli) — restores window column position after exiting fullscreen.
{inputs, ...}: {
  flake-file.inputs.niri-scratchpad = {
    url = "github:gvolpe/niri-scratchpad";
  };

  flake-file.inputs.nfsm = {
    url = "github:gvolpe/nfsm";
  };

  den.aspects.niri = {
    homeManager = {pkgs, ...}: let
      nirius = pkgs.nirius;
      nscratch = inputs.niri-scratchpad.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # Wrapper scripts for apps with arguments (nscratch -s takes a single command).
      spawn1password = pkgs.writeShellScript "spawn-1password" ''exec 1password'';
      spawnKittyDropdown = pkgs.writeShellScript "spawn-kitty-dropdown" ''exec kitty --class kitty-dropdown'';
    in {
      imports = [inputs.nfsm.homeModules.default];

      home.packages = [nirius nscratch];

      services.nfsm = {
        enable = true;
        package = inputs.nfsm.packages.${pkgs.stdenv.hostPlatform.system}.nfsm;
        enableCli = true;
        cliPackage = inputs.nfsm.packages.${pkgs.stdenv.hostPlatform.system}.nfsm-cli;
      };

      programs.niri.settings = {
        # Named workspaces: 1-5 for regular use, "scratch" for scratchpad apps.
        # Alphabetical sort ensures scratch comes last (index 6).
        workspaces = {
          "1" = {};
          "2" = {};
          "3" = {};
          "4" = {};
          "5" = {};
          "scratch" = {};
        };

        spawn-at-startup = [
          # Daemons
          {argv = ["${nirius}/bin/niriusd"];}

          # Scratchpad apps — window rules redirect to "scratch" workspace
          {argv = ["slack"];}
          {argv = ["1password" "--silent"];}
          {argv = ["spotify" "--minimized"];}
          {argv = ["enteauth"];}
          {argv = ["kitty" "--class" "kitty-dropdown"];}
        ];

        # Window rules: scratchpad apps always open on "scratch" workspace, floating.
        # This ensures apps ONLY exist in the scratchpad — even if launched from rofi.
        window-rules = [
          {
            matches = [{app-id = "^Slack$";}];
            open-on-workspace = "scratch";
            open-floating = true;
          }
          {
            matches = [{app-id = "^1password$";}];
            open-on-workspace = "scratch";
            open-floating = true;
          }
          {
            matches = [{app-id = "^Spotify$";}];
            open-on-workspace = "scratch";
            open-floating = true;
          }
          {
            matches = [{app-id = "^enteauth$";}];
            open-on-workspace = "scratch";
            open-floating = true;
          }
          {
            matches = [{app-id = "^kitty-dropdown$";}];
            open-on-workspace = "scratch";
            open-floating = true;
          }
        ];

        # Per-app scratchpad keybinds (nscratch — spawns if not running via -s).
        binds = {
          "Mod+Shift+S".action.spawn = ["${nscratch}/bin/nscratch" "-id" "Slack" "-s" "slack"];
          "Mod+Shift+E".action.spawn = ["${nscratch}/bin/nscratch" "-id" "enteauth" "-s" "enteauth"];
          "Mod+Shift+O".action.spawn = ["${nscratch}/bin/nscratch" "-id" "1password" "-s" "${spawn1password}"];
          "Mod+Shift+M".action.spawn = ["${nscratch}/bin/nscratch" "-id" "Spotify" "-s" "spotify"];
          "Mod+Grave".action.spawn = ["${nscratch}/bin/nscratch" "-id" "kitty-dropdown" "-s" "${spawnKittyDropdown}"];
        };
      };
    };
  };
}
