{ inputs, ... }:
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.stylix = {
    homeManager =
      { pkgs, ... }:
      let
        apple = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        imports = [ inputs.stylix.homeModules.stylix ];
        stylix = {
          enable = true;
          autoEnable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";

          fonts = {
            sansSerif = {
              package = apple.sf-pro;
              name = "SF Pro Display";
            };
            serif = {
              package = pkgs.noto-fonts;
              name = "Noto Serif";
            };
            monospace = {
              package = apple.sf-mono;
              name = "SF Mono";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };
          };

          targets = {
            # Disabled: custom styling or not in use
            waybar.enable = false;
            hyprland.enable = false;
            hyprlock.enable = false;
            # Kitty and ghostty use Iosevka, not SF Mono
            kitty.fonts.enable = false;
            ghostty.fonts.enable = false;
            rofi.fonts.enable = false;
            zen-browser.profileNames = [ "Default Profile" ];
            # Kvantum (stylix Qt target) has a qtsvg version mismatch that breaks
            # Qt apps (broken fonts, no dark theme). Use gtk3 platform theme instead
            # so Qt apps inherit the GTK dark theme directly.
            qt.enable = false;
          };
        };
        qt = {
          enable = true;
          platformTheme.name = "gtk3";
          style = {
            name = "adwaita-dark";
            package = pkgs.adwaita-qt;
          };
        };
        # Prevent Qt from re-querying XWayland DPI on output topology changes
        # (e.g. KVM switch), which causes font cache mismatches and broken rendering.
        home.sessionVariables.QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      };
  };
}
