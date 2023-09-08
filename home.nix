{ config, pkgs, ... }:
let
  username = "deus";
  homeDirectory = "/home/deus";
in {
  home = {
    username = username;
    stateVersion = "23.05";
    homeDirectory = homeDirectory;
    packages = with pkgs; [
      catppuccin-cursors.mochaDark
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
    ];
  };
  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hp: [
        hp.dbus
        hp.xmonad
        hp.xmonad-contrib
      ];
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
    rofi.enable = true;
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
      completionInit = "";
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
        setopt glob_dots     # no special treatment for file names with a leading dot
        setopt no_auto_menu  # require an extra TAB press to open the completion menu

        export EDITOR=nvim
        export VISUAL=nvim
        export XDG_CACHE_HOME=$HOME/.cache
        export XDG_CONFIG_HOME=$HOME/.config
        export XDG_DATA_HOME=$HOME/.local/share
        export XDG_STATE_HOME=$HOME/.local/state
        export PATH="$HOME/.pyenv/bin:$PATH"
        export PATH="/home/deus/.local/share/fnm:$PATH"
        export BAT_THEME="Catppuccin-mocha"
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
