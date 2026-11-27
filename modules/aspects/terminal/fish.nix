{
  den.aspects.terminal = {
    homeManager =
      { pkgs, ... }:
      {
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting # Disable greeting message
          '';
          shellInit = ''
            set -U fish_escape_delay_ms 30
          '';
          shellAliases = {
            ll = "eza -l";
            la = "eza -la";
            lt = "eza --tree";
            fbf = "tmuxp load fj";
          };
          plugins = with pkgs.fishPlugins; [
            {
              name = "pure";
              inherit (pure) src;
            }
            {
              name = "plugin-git";
              inherit (plugin-git) src;
            }
            {
              name = "fzf-fish";
              inherit (fzf-fish) src;
            }
            {
              name = "git-abbr";
              inherit (git-abbr) src;
            }
            {
              name = "plugin-sudope";
              inherit (plugin-sudope) src;
            }
            {
              name = "sponge";
              inherit (sponge) src;
            }
            {
              name = "colored-man-pages";
              inherit (colored-man-pages) src;
            }
          ];
          functions = {
            fish_command_not_found = {
              body = "__fish_default_command_not_found_handler $argv[1]";
            };
            gitignore = "curl -sL https://www.gitignore.io/api/$argv";
          };
        };
      };
  };
}
