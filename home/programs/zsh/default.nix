{
  enable = true;
  autocd = true;
  dotDir = ".config/zsh";
  antidote =
    # TODO: convert to a separate method
    let list = [ (builtins.readFile ./plugins.txt) ];
    in {
      enable = true;
      useFriendlyNames = true;
      plugins = list;
    };
  shellAliases = {
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
    lst = "eza -T";
    copy = ''
      pwd | tr -d '
      ' | pbcopy'';
    rebuild =
      "sudo nixos-rebuild switch --flake '.#cognixm' --option eval-cache false";
  };
  initExtraFirst = ''
    autoload -Uz compinit && compinit
    fpath=($fpath autoloaded)
    fpath+=($ZDOTDIR/.antidote/plugins/pure)
  '';
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

}
