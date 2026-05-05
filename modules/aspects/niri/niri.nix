# Niri compositor — scrollable-tiling Wayland compositor.
# Uses the collector pattern: layout.nix, input.nix, binds.nix also define
# den.aspects.niri and their settings are merged together by den.
{ inputs, ... }:
{
  flake-file.inputs.niri-flake = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.niri = {
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

    # HM module is auto-imported by the NixOS module when HM is a NixOS module.
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wl-clipboard
          grimblast
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
