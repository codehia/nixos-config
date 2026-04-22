# Combined appearance aspect: stylix (base16 theming) + catppuccin/nix (per-app modules).
# stylix handles: fonts, cursor, zen, base16 color schemes for most apps.
# catppuccin/nix handles: fish, bat, fzf, lazygit, ghostty, kitty, rofi, kvantum.
{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.appearance = {
    nixos =
      { ... }:
      {
        imports = [ inputs.catppuccin.nixosModules.catppuccin ];
        # Set Qt theme vars at the system level so all sessions (greetd-started
        # compositors, D-Bus activated apps, xdg-open chains) inherit them.
        environment.sessionVariables = {
          QT_AUTO_SCREEN_SCALE_FACTOR = "0";
          QT_QPA_PLATFORMTHEME = "kvantum";
          QT_STYLE_OVERRIDE = "kvantum";
        };
      };

    homeManager =
      { pkgs, ... }:
      let
        apple = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        imports = [
          inputs.stylix.homeModules.stylix
          inputs.catppuccin.homeModules.catppuccin
        ];

        catppuccin = {
          flavor = "mocha";
          enable = true;
          nvim.enable = false; # configured directly in init.lua
          kvantum.enable = true; # Qt theming via Kvantum
          cursors.enable = false; # stylix.cursor handles this
          # stylix handles these — catppuccin would double-theme them
          ghostty.enable = false;
          kitty.enable = false;
          lazygit.enable = false;
          delta.enable = false; # managed via git.nix with mellow-barbet
          tmux.enable = false;
          hyprland.enable = false;
          rofi.enable = false;
          fish.enable = true; # no stylix fish target
        };

        stylix = {
          enable = true;
          autoEnable = true;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";

          cursor = {
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-light";
            size = 32;
          };

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
            waybar.enable = false;
            hyprland.enable = false;
            hyprlock.enable = false;
            kitty.fonts.enable = false; # Iosevka font set directly in kitty config
            ghostty.enable = false; # JetBrainsMono set directly in ghostty config
            rofi.fonts.enable = false;
            # catppuccin/nix handles these with purpose-built mocha colors
            bat.enable = false;
            fzf.enable = false;
            lazygit.enable = false;
            yazi.enable = false;
            # Qt handled by catppuccin.kvantum instead
            qt.enable = false;
            zen-browser.profileNames = [ "Default Profile" ];
          };
        };

        # GTK: adw-gtk3 without -dark follows gsettings color-scheme natively,
        # so the DMS dark mode toggle propagates correctly to Nautilus etc.
        gtk.theme = {
          package = lib.mkForce pkgs.adw-gtk3;
          name = lib.mkForce "adw-gtk3";
        };

        gtk.iconTheme = {
          package = lib.mkForce pkgs.tela-circle-icon-theme;
          name = lib.mkForce "Tela-circle-dark";
        };

        # Default to dark; DMS toggle writes to this key at runtime.
        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

        # Qt: Kvantum platform theme; catppuccin.kvantum installs the Mocha theme files.
        qt = {
          enable = true;
          platformTheme.name = "kvantum";
          style.name = "kvantum";
        };
      };
  };
}
