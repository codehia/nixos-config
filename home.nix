{ config, pkgs, ... }:
let
  username = "deus";
  homeDirectory = "/home/deus";
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
      tmux
      lazygit
      xclip
      xsel
      git
      nixfmt
      eza
      xmobar
      feh
      trayer
    ];
  };
  services = let
    bars = builtins.readFile ./bars.ini;
    colors = builtins.readFile ./colors.ini;
    mods1 = builtins.readFile ./modules.ini;
    mods2 = builtins.readFile ./user_modules.ini;
    xmonad = ''
      [module/xmonad]
      type = custom/script
      exec = xmonadpropread
      tail = true
    '';
  in {
    polybar = {
      enable = false;
      script = ''
        polybar top &
      '';
      config = {
        "bar/top" = {
          monitor = "\${env:MONITOR:eDP}";
          width = "100%";
          height = "3%";
          radius = 0;
          modules-center = "date";
        };

        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d.%m.%y";
          time = "%H:%M";
          label = "%time%  %date%";
        };
      };
      extraConfig = xmonad;
    };
    picom = {
      enable = true;
    };
    trayer = {
      enable = false;
    };
  };
  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: [ hp.dbus hp.xmonad hp.xmonad-contrib ];
      config = ./xmonad.hs;
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Pink-dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "standard";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };
  };
  programs = {
    ssh.enable = true;
    home-manager.enable = true;
    feh = {
      enable = false;
    };
    xmobar = {
      enable = true;
      extraConfig = ''
        Config {  bgColor = "#11111b"
               , fgColor = "#cdd6f4"
               , alpha = 254
               , position = TopSize L 100 24 
               , lowerOnStart = True
               , hideOnStart = False
               , allDesktops = False
               , persistent = True
               , iconRoot = ".config/xmonad/xpm/"
               , overrideRedirect = True
               , commands = [ Run XPropertyLog "_XMONAD_LOG_0"
                              -- Time and date -- 30 seconds
                            , Run Date "<fc=#81A1C1><fc=#D8DEE9>%I:%M %p</fc> %a %_d %b %Y</fc>" "date" 300
                              -- Disk space free -- 30 minute 
                            , Run DiskU [("/", "<fc=#88C0D0><fn=1> </fn><free></fc> ")] [] 18000 -- Shows total free space on the root partition
                              -- Ram used number and percent -- 2 seconds
                            , Run Memory ["--template", "<fc=#A3BE8C><fn=1> </fn><usedratio></fc> " , "-S", "On" ] 20
                              -- Cpu usage in percent -- 5 seconds
                            , Run Cpu ["--template", "<fc=#EBCB8B><fn=1> </fn><total></fc> " , "-S", "On" ,"-H","50" ,"--high","red"] 50
                              -- Show CPU temperature -- 1 minute
                              -- This script uses pacman-contrib package to work
                            , Run Com ".local/bin/checkupdate" [] "checkupdate" 72000
                              -- Network up and down -- 2 seconds
                            , Run DynNetwork ["--template", " <fc=#98be65><rx> <fc=#39ff14><fn=1> </fn></fc><fc=#ff9f00><fn=1> </fn></fc> <tx> </fc> " , "-S", "True"] 20
                              -- Wireless Interface -- 2 minute 
                            , Run Wireless "wlp2s0" ["--template", "<fn=1><fc=#ecd534><qualitybar> </fc></fn>"
                                                       , "-W", "0" , "-f", "睊直直直直直直直直" , "-L", "5", "-l", "#FF0000" ] 1200
                              -- Runs a standard shell command 'uname -r' to get kernel version -- 2 hour
                            , Run Com "uname" ["-s","-r"] "" 0
                              -- Shift all icons to the left to accomodate system tray -- 5 seconds
                            , Run Com ".local/bin/trayer-padding-icon.sh" ["panel"] "trayerpad" 50
        		    , Run Battery ["--template", "<fc=#81A1C1><acstatus></fc>"
                                           , "-S", "On", "-d", "0", "-m", "2" --suffix false(default), --ddigits 0 decimal places to show, --minWidth 2 characters(can be padded with -c/--padchars string)
                                           , "-L", "20", "-H", "80", "-p", "3" --Low , --High, --ppad pads percentage values with 3 characters
                                           , "-W", "0" --bwidth total number of characters used to draw bars (default 10)
                                           , "-f", "" -- Choose icon for leftbar depending on battery remaining --bfore characters used to draw bars (cyclically)
                                           , "--" -- Monitor specific data below
                                           --, "-P" --shows the percentage symbol
                                           , "-a", "notify-send -u critical 'Battery running out!'"
                                           , "-A", "10"
                                           , "-i", "<left><fn=1> <leftbar>  <fc=#39ff14>ﮣ </fc></fn>" -- Charged (The two spaces are to render the battery icon fully, after which the plug icon comes, which takes 2 cells to render, so one empty space)
                                           , "-O", "<left><fn=1> <leftbar>  <fc=#ff9f00> </fc></fn>" -- Charging
                                           , "-o", "<left><fn=1> <leftbar>  <fc=#39ff14>ﮤ </fc></fn>" -- Discharging
                                           , "-H", "8", "-L", "5" 
                                           , "-l", "green", "-m", "grey", "-h", "red" -- Shows an approximation of rate of battery discharge
                                           ] 600
                            ]
               , sepChar = "%"
               , alignSep = "}{"
               , template = "<fn=1>   </fn>%_XMONAD_LOG_0%}%date%{ %disku% %memory% %cpu% <fc=#D08770><fn=1> </fn>%checkupdate%</fc> %trayerpad%"
        }
      '';
    };
    #autorandr = {
    #  eanble = true;
    #  profiles = let
    #    edp1 =
    #      "00ffffffffffff0006af3d5700000000001c0104a51f1178022285a5544d9a270e505400000001010101010101010101010101010101b43780a070383e401010350035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30352e37200a0070";
    #    dp2 =
    #      "00ffffffffffff004c2d7d7035424430041f010380351e782adfd5a35b4da1250d5054bfef8081c0810081809500a9c0b300714f0101023a801871382d40582c450010292100001e000000fd00304b1e5412000a202020202020000000fc004c4632345433350a2020202020000000ff00484e41523130313039340a2020015202031cb146901f0413131367030c0010000024681a00000101004b00011d00bc52d01e20b828554010292100001e011d007251d01e206e285500102921000018011d007251d01e206e285500102921000018011d007251d01e206e28550010292100001e2a4480a0703827403020350010292100001a000000000000000000dc";
    #  in {
    #    default = {
    #      fingerprint = { eDP1 = edp1; };
    #      config = {
    #        eDP1 = {
    #          enable = true;
    #          primary = true;
    #        };
    #      };

    #    };
    #  };
    #};
    rofi = {
      enable = true;
      extraConfig = {
        modi = "run,drun,window";
        icon-theme = "Oranchelo";
        show-icons = true;
        terminal = "kitty";
        drun-display-format = "{icon} {name}";
        location = 0;
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 﩯  Window";
        display-Network = " 󰤨  Network";
        sidebar-mode = true;
      };
      theme = ./catppuccin-mocha.rasi;
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
    zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      initExtraFirst = ''
        autoload -Uz compinit && compinit
        fpath=($fpath autoloaded)
        fpath+=($ZDOTDIR/.antidote/plugins/pure)
      '';
      shellAliases = {
        tree = "tree -a -I .git";
        pbcopy = "xclip -selection clipboard";
        pbpaste = "xclip -selection clipboard -o";
        lst = "exa -T";
        copy = ''
          pwd | tr -d '
          ' | pbcopy'';
      };
      initExtra = ''
        autoload -U promptinit; promptinit
        prompt pure

        bindkey '^ ' autosuggest-accept
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
        bindkey "^[[H" beginning-of-line
        bindkey "^[[F" end-of-line
        bindkey '^H' backward-kill-word
        bindkey '5~' kill-word

        export EDITOR=nvim
        export VISUAL=nvim
        export XDG_CACHE_HOME=$HOME/.cache
        export XDG_CONFIG_HOME=$HOME/.config
        export XDG_DATA_HOME=$HOME/.local/share
        export XDG_STATE_HOME=$HOME/.local/state
        export PATH="$HOME/.pyenv/bin:$PATH"
        export PATH="/home/deus/.local/share/fnm:$PATH"
        export BAT_THEME="Catppuccin-mocha"

        setopt glob_dots     # no special treatment for file names with a leading dot
        setopt no_auto_menu  # require an extra TAB press to open the completion menu
      '';

      antidote = {
        enable = true;
        useFriendlyNames = true;
        plugins = [
          "agkozak/zsh-z"
          "sindresorhus/pure"
          "ohmyzsh/ohmyzsh path:lib"
          "ohmyzsh/ohmyzsh path:plugins/extract"
          "ohmyzsh/ohmyzsh path:plugins/sudo"
          "ohmyzsh/ohmyzsh path:plugins/web-search"
          "ohmyzsh/ohmyzsh path:plugins/git"
          "ohmyzsh/ohmyzsh path:plugins/gitfast"
          "zsh-users/zsh-autosuggestions kind:defer"
          "zsh-users/zsh-history-substring-search kind:defer"
          "zdharma-continuum/fast-syntax-highlighting kind:defer"
          "zsh-users/zsh-completions"
          "Tarrasch/zsh-autoenv"
          "mroth/evalcache"
          "Aloxaf/fzf-tab"
        ];
      };
    };
  };
}
