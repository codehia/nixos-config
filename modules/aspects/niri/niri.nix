# Niri compositor — scrollable-tiling Wayland compositor.
# Uses the collector pattern: layout.nix, input.nix, binds.nix, plugins.nix also define
# den.aspects.niri and their settings are merged together by den.
#
# The compositor itself is system-level: the nixos block lives in den.aspects.wm-sessions
# (a collector shared by all WM aspects, included by graphical-session) so the session
# registers with services.displayManager.sessionPackages and appears in the greeter.
# The HM config half reaches every user via the den.aspects.wm-configs collector (den.default).
{ den, inputs, ... }:
{
  flake-file.inputs.niri-flake = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.wm-configs.includes = [ den.aspects.niri ];

  den.aspects.wm-sessions = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.niri-flake.nixosModules.niri ];
        nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
        programs.niri = {
          enable = true;
          package = pkgs.niri-stable;
        };
      };
  };

  den.aspects.niri = {
    # HM module is auto-imported by the NixOS module when HM is a NixOS module.
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wl-clipboard
          grim
          slurp
          satty
        ];

        programs.niri.settings = {
          # App spawns + stashing handled in plugins.nix

          environment = {
            NIXOS_OZONE_WL = "1";
            DISPLAY = null; # xwayland-satellite sets this
          };

          xwayland-satellite.enable = true;

          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
          hotkey-overlay.skip-at-startup = true;
        };
      };
  };
}
