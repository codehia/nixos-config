{ ... }:
{
  den.aspects.tmux = {
    homeManager =
      { pkgs, ... }:
      let
        dotbar = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-dotbar";
          version = "714ba5994f8857571d6146b1f3612949ae91f820";
          src = pkgs.fetchFromGitHub {
            owner = "vaaleyard";
            repo = "tmux-dotbar";
            rev = "714ba5994f8857571d6146b1f3612949ae91f820";
            sha256 = "sha256-n9k18pJnd5mnp9a7VsMBmEHDwo3j06K6/G6p7/DTyIY=";
          };
          rtpFilePath = "dotbar.tmux";
        };
      in
      {
        programs.tmux = {
          shell = "${pkgs.fish}/bin/fish";
          terminal = "tmux-256color";
          historyLimit = 100000;
          enable = true;
          prefix = "C-a";
          baseIndex = 1;
          newSession = true;
          tmuxp.enable = true;
          plugins = with pkgs; [
            dotbar
            tmuxPlugins.sensible
          ];
          extraConfig = ''
            # split current window horizontally
            bind - split-window -v
            # split current window vertically
            bind _ split-window -h

            # pane navigation
            bind -r h select-pane -L  # move left
            bind -r j select-pane -D  # move down
            bind -r k select-pane -U  # move up
            bind -r l select-pane -R  # move right
            bind > swap-pane -D       # swap current pane with the next one
            bind < swap-pane -U       # swap current pane with the previous one

            # maximize current pane
            bind + run "cut -c3- '#{TMUX_CONF}' | sh -s _maximize_pane '#{session_name}' '#D'"

            # pane resizing
            bind -r H resize-pane -L 2
            bind -r J resize-pane -D 2
            bind -r K resize-pane -U 2
            bind -r L resize-pane -R 2

            # window navigation
            unbind n
            unbind p
            bind -r p previous-window # select previous window
            bind -r n next-window     # select next window
            bind Tab last-window      # move to last active window

            # Toggle status bar
            bind-key b set-option status
            # Toggle mouse on/off
            bind-key m  set-option -g mouse \; display-message 'Mouse #{?mouse,on,off}'

            # -- display -------------------------------------------------------------------
            set -g pane-active-border-style "bg=default,fg=colour166"
            set -g pane-border-style "bg=default,fg=colour245"
            set -g pane-border-lines "heavy"

            set -g base-index 1           # start windows numbering at 1
            setw -g pane-base-index 1     # make pane numbering consistent with windows

            setw -g automatic-rename on   # rename window to reflect current program
            set -g renumber-windows on    # renumber windows when a window is closed

            set -g set-titles on          # set terminal title

            set -g display-panes-time 800 # slightly longer pane indicators display time
            set -g display-time 1000      # slightly longer status messages display time

            set -g status-interval 10     # redraw status line every 10 seconds

            # clear both screen and history
            bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history

            # activity
            set -g monitor-activity on
            set -g visual-activity off
          '';
        };
      };
  };
}
