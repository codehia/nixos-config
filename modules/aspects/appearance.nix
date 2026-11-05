# Combined appearance aspect: stylix (base16 theming) + catppuccin/nix (per-app modules).
# stylix handles: fonts, cursor, zen, kitty, fish terminal palette, base16 schemes for most apps.
# catppuccin/nix handles: fish syntax colors, bat, fzf, lazygit, ghostty, yazi, kvantum.
{
  den,
  inputs,
  lib,
  ...
}:
let
  # Every font choice lives here; fontconfig, stylix, GTK, DMS and the
  # terminals all read from this block. Helium keeps Chromium's own defaults.
  fonts = {
    sans = "SF Pro Text";
    serif = "New York";
    mono = "SF Mono";
    emoji = "Noto Color Emoji";
    terminal = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
  };
in
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # System fonts + rendering. Stylix (NixOS module) owns the font choice: its
  # fontconfig + font-packages targets set the generic families and install the
  # fonts, and home-manager inherits them (homeManagerIntegration.followSystem).
  # autoEnable = false: system-level theming of anything else stays off, so it
  # never clashes with catppuccin (tty) or boot.nix (plymouth).
  # Rendering: grayscale AA + slight hinting.
  den.aspects.fonts = {
    nixos =
      { pkgs, inputs', ... }:
      let
        apple = inputs'.apple-fonts.packages;
      in
      {
        imports = [ inputs.stylix.nixosModules.stylix ];

        stylix = {
          enable = true;
          autoEnable = false;
          overlays.enable = false;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          targets.fontconfig.enable = true;
          targets.font-packages.enable = true;
          fonts = {
            sansSerif = {
              package = apple.sf-pro;
              name = fonts.sans;
            };
            serif = {
              package = apple.ny;
              name = fonts.serif;
            };
            monospace = {
              package = apple.sf-mono;
              name = fonts.mono;
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = fonts.emoji;
            };
          };
        };

        fonts = {
          fontconfig = {
            enable = true;
            antialias = true;
            hinting = {
              enable = true;
              style = "slight";
            };
            subpixel = {
              rgba = "none";
              lcdfilter = "none";
            };
            # Fallbacks after stylix's primary family (stylix inserts first).
            defaultFonts = {
              sansSerif = [ "Noto Sans CJK SC" ];
              serif = [ "Noto Serif CJK SC" ];
              monospace = [ "Symbols Nerd Font Mono" ];
            };
          };
          packages = with pkgs; [
            corefonts # real Arial / Times New Roman for Chromium's web defaults
            noto-fonts
            noto-fonts-color-emoji
            noto-fonts-monochrome-emoji
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            jetbrains-mono
            nerd-fonts.jetbrains-mono
            nerd-fonts.iosevka
            font-awesome
            material-icons
            nerd-fonts.symbols-only
            powerline-fonts
          ];
        };
      };

    includes = [ (den._.unfree [ "corefonts" ]) ];
  };

  den.aspects.appearance = {
    nixos = {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];
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
      { pkgs, ... }:
      {
        # stylix's HM module is auto-imported by the NixOS module (fonts aspect),
        # which also passes its fonts down.
        imports = [ inputs.catppuccin.homeModules.catppuccin ];

        catppuccin = {
          flavor = "mocha";
          enable = true;
          nvim.enable = false; # configured directly in init.lua
          kvantum.enable = true; # Qt theming via Kvantum
          cursors.enable = false; # stylix.cursor handles this
          # stylix.targets.{ghostty,lazygit} are off — catppuccin owns these
          ghostty.enable = true;
          lazygit.enable = true;
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

          targets = {
            dank-material-shell.enable = false;
            hyprland.enable = false;
            hyprlock.enable = false;
            kitty.fonts.enable = false; # fonts.terminal, set below
            ghostty.enable = false; # fonts.terminal, set below
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

        dconf.settings."org/gnome/desktop/interface" = {
          # Default to dark; DMS toggle writes to this key at runtime.
          color-scheme = "prefer-dark";
          # GTK reads these via the settings portal (it overrides settings.ini).
          # "manual" makes GTK4 use them instead of its own built-in choice.
          font-rendering = "manual";
          font-antialiasing = "grayscale";
          font-hinting = "slight";
        };
        # Whole-pixel glyph advances; not exposed through the portal.
        gtk.gtk4.extraConfig.gtk-hint-font-metrics = true;

        programs.ghostty.settings = {
          font-family = fonts.terminal.name;
          font-size = fonts.terminal.size;
        };
        programs.kitty.font = fonts.terminal;

        programs.dank-material-shell.settings = {
          fontFamily = fonts.sans;
          monoFontFamily = fonts.mono;
          textRenderType = 1; # Native: hinted glyphs (default Qt = distance field)
        };

        # Qt: Kvantum platform theme; catppuccin.kvantum installs the Mocha theme files.
        qt = {
          enable = true;
          platformTheme.name = "kvantum";
          style.name = "kvantum";
        };
      };
  };
}
