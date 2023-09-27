{ config, pkgs, ... }:
let
  username = "deus";
  homeDirectory = "/home/deus";
  system = "x86_64-linux";
in {
  home = {
    username = username;
    stateVersion = "23.05";
    homeDirectory = homeDirectory;
    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "Catppuccin-Mocha-Dark-Cursors";
    };
    packages = with pkgs; [
      neovim
      kitty
      brave
      htop
      fzf
      ripgrep
      bat
      lazygit
      xclip
      xsel
      git
      nixfmt
      eza
      material-icons
      material-design-icons
      roboto
      work-sans
      comic-neue
      source-sans
      twemoji-color-font
      comfortaa
      inter
      lato
      lexend
      jost
      dejavu_fonts
      iosevka-bin
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      jetbrains-mono
      (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
    ];
  };
  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        settings = {
          "$mainMod" = "ALT";
          monitor = "eDP-1, 1920x1080@60, 0x0, 1";
          decoration = {
            blur = { enabled = true; };
            dim_inactive = true;
          };
          input = {
            follow_mouse = 0;
            mouse_refocus = false;
          };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            enable_swallow = true;
          };
          general = {
            layout = "master";
            border_size = 4;
            no_border_on_floating = true;
            "col.active_border" = "rgb(e64553)";
          };
          bind = [
            "$mainMod, P, exec, rofi -show drun -show-icons"
            "$mainMod SHIFT, RETURN, exec, kitty"
            "$mainMod, b, exec, brave"
            "$mainMod SHIFT, C, killactive,"
            "$mainMod SHIFT, code:21,  fullscreen ,1"
            "$mainMod, h, movefocus, l"
            "$mainMod, j, movefocus, d"
            "$mainMod, k, movefocus, u"
            "$mainMod, l, movefocus, r"
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod, m, layoutmsg, focusmaster"
            "$mainMod, RETURN, layoutmsg, swapwithmaster"
            "$mainMod, z, focuscurrentorlast,"
          ];
        };
      };
    };
  };
  fonts.fontconfig.enable = true;
  gtk = { font.name = "Noto Color Emoji"; };
  services = {
    mako = {
      enable = true;
    };
  };
  programs = let zshConfig = import ./programs/zsh;
  in {
    ssh.enable = true;
    home-manager.enable = true;
    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 70;
          output = [ "eDP-1" ];
          modules-left =
            [ "hyprland/workspaces" "hyprland/mode" "wlr/taskbar" ];
          modules-center = [ "hyprland/window" "custom/hello-from-waybar" ];
          modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
          };
          "custom/hello-from-waybar" = {
            format = "hello {}";
            max-length = 40;
            interval = "once";
            exec = pkgs.writeShellScript "hello-from-waybar" ''
              echo "from within waybar"
            '';
          };
        };
      };
    };
    tmux = {
      enable = true;
      clock24 = false;
      prefix = "C-a";
      sensibleOnTop = true;
      shortcut = "a";
      terminal = "screen-256color";
      newSession = false;
      baseIndex = 1;
      tmuxp.enable = true;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.nord;
          extraConfig = ''
            set -g @nord_tmux_no_patched_font "1"
          '';
        }
        tmuxPlugins.cpu
        tmuxPlugins.battery
        tmuxPlugins.pain-control
        tmuxPlugins.sensible
        tmuxPlugins.yank
      ];
    };
    git = {
      enable = true;
      diff-so-fancy.enable = true;
      userName = "codehia";
      userEmail = "dev@sacharya.dev";
    };
    kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      settings = {
        window_padding_width = "2 8";
        cursor_shape = "block";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };
      shellIntegration = {
        mode = "no-cursor";
        enableZshIntegration = true;
      };
      font = {
        package = pkgs.nerdfonts;
        name = "JetBrainsMono NF";
        size = 14.0;
      };
    };
    eza = {
      enable = true;
      enableAliases = true;
      icons = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux = {

        enableShellIntegration = true;
      };
      colors = {
        bg = "#1e1e2e";
        "bg+" = "#313244";
        hl = "#f38ba8";
        "hl+" = "#f38ba8";
        fg = "#cdd6f4";
        "fg+" = "#cdd6f4";
        header = "#f38ba8";
        info = "#cba6f7";
        pointer = "#f5e0dc";
        marker = "#f5e0dc";
        prompt = "#cba6f7";
        spinner = "#f5e0dc";
      };
      fileWidgetOptions = [
        "--preview 'echo {}'"
        "--preview-window up:3:hidden:wrap"
        "--bind 'ctrl-/:toggle-preview'"
        "--header 'Press CTRL-/ to toggle preview'"
        "--bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort'"
        "--header 'Press CTRL-Y to copy command into clipboard'"
      ];
    };
    zsh = zshConfig;
  };
}
