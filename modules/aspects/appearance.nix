# Combined appearance aspect: stylix (base16 theming) + catppuccin/nix (per-app modules).
# stylix handles: fonts, cursor, zen, kitty, fish terminal palette, base16 schemes for most apps.
# catppuccin/nix handles: fish syntax colors, bat, fzf, ghostty, yazi, kvantum.
{
  inputs,
  lib,
  ...
}:
let
  # catppuccin/nix compiles whiskers (Rust) from source for every port; swap in the
  # cache.nixos.org build from unstable (same version, 2.9.0).
  # ponytail: drop once catppuccin/nix uses nixpkgs' catppuccin-whiskers itself
  catppuccinSources =
    pkgs:
    (import inputs.catppuccin { inherit pkgs; }).packages.overrideScope (
      _: _: { whiskers = pkgs.unstable.catppuccin-whiskers; }
    );
in
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.appearance = {
    nixos = { pkgs, ... }: {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];
      catppuccin.sources = catppuccinSources pkgs;
      # Mocha VT palette (console.colors) — the Linux console approximates all
      # colors to its 16-slot palette, so this is what makes tuigreet's named
      # theme colors render as Catppuccin hues.
      catppuccin = {
        enable = true;
        flavor = "mocha";
        tty.enable = true;
        # Boot splash stays "connect" (boot.nix) — catppuccin would conflict on
        # boot.plymouth.theme otherwise. Only the splash theme; plymouth itself stays on.
        plymouth.enable = false;
      };
      # Set Qt theme vars at the system level so all sessions (greetd-started
      # compositors, D-Bus activated apps, xdg-open chains) inherit them.
      environment.sessionVariables = {
        QT_AUTO_SCREEN_SCALE_FACTOR = "0";
        QT_QPA_PLATFORMTHEME = "kvantum";
        QT_STYLE_OVERRIDE = "kvantum";
      };
    };

    homeManager =
      { pkgs, inputs', ... }:
      let
        apple = inputs'.apple-fonts.packages;
      in
      {
        imports = [
          inputs.stylix.homeModules.stylix
          inputs.catppuccin.homeModules.catppuccin
        ];

        catppuccin = {
          flavor = "mocha";
          enable = true;
          sources = catppuccinSources pkgs;
          nvim.enable = false; # configured directly in init.lua
          kvantum.enable = true; # Qt theming via Kvantum
          cursors.enable = false; # stylix.cursor handles this
          # stylix.targets.ghostty is off — catppuccin owns it
          ghostty.enable = true;
          # theme file uses old gui.authorColors; lazygit 0.66 tries to migrate it in /nix/store and exits
          lazygit.enable = false;
          kitty.enable = false; # stylix themes kitty
          delta.enable = false; # managed via git.nix with mellow-barbet
          tmux.enable = false;
          hyprland.enable = false;
          fish.enable = true; # fish syntax colors (stylix only sets the terminal palette)
        };

        stylix = {
          enable = true;
          autoEnable = true;
          # HM-side overlays are ignored under home-manager.useGlobalPkgs (and warn).
          overlays.enable = false;
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
              name = "SF Pro";
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
            dank-material-shell.enable = false;
            hyprland.enable = false;
            hyprlock.enable = false;
            kitty.fonts.enable = false; # Iosevka font set directly in kitty config
            ghostty.enable = false; # JetBrainsMono set directly in ghostty config
            # catppuccin/nix handles these with purpose-built mocha colors
            bat.enable = false;
            fzf.enable = false;
            yazi.enable = false;
            # Qt handled by catppuccin.kvantum instead
            qt.enable = false;
            gtk.flatpakSupport.enable = false; # no flatpak apps; avoids ~/.themes
            zen-browser.profileNames = [ "Default Profile" ];
          };
        };

        # GTK: adw-gtk3 without -dark follows gsettings color-scheme natively,
        # so the DMS dark mode toggle propagates correctly to Nautilus etc.
        gtk.theme = {
          package = lib.mkForce pkgs.adw-gtk3;
          name = lib.mkForce "adw-gtk3";
        };

        # cursor already lives in ~/.local/share/icons (on XCURSOR_PATH); skip ~/.icons
        home.pointerCursor.dotIcons.enable = false;

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
