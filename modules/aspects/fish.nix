{
  den.aspects.fish = {
    nixos.programs.fish.enable = true;

    homeManager =
      { pkgs, ... }:
      {
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting # Disable greeting message
            # ---- direnv helpers & hook (works on Home-Manager 25.05) ----

            # global list of currently-registered names (functions/aliases)
            set -g __direnv_loaded_funcs

            function __direnv_register
              set -l name $argv[1]
              if test -z "$name"
                return 1
              end

              # join the rest of the args into the code string and evaluate
              set -l code (string join " " $argv[2..-1])
              eval $code

              if not set -q __direnv_loaded_funcs
                set -g __direnv_loaded_funcs $name
              else
                set -g __direnv_loaded_funcs $__direnv_loaded_funcs $name
              end
            end

            function __direnv_unload_all
              if set -q __direnv_loaded_funcs
                for f in $__direnv_loaded_funcs
                  if functions --query $f
                    functions -e $f
                  end
                end
                set -e __direnv_loaded_funcs
              end
            end

            # unload previous, import direnv exports, then source project fish snippet (if present)
            function __direnv_fish_hook --on-event fish_prompt
              __direnv_unload_all

              # import env vars from direnv (safe: this only evaluates direnv's exported env)
              # direnv export fish | source

              # if project set FISH_DIR_ENV in .envrc, source it
              if set -q FISH_DIR_ENV
                if test -f $FISH_DIR_ENV
                  source $FISH_DIR_ENV
                end
              end
            end

            # ---- end direnv helpers ----
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
              name = "z";
              src = z;
            }
            {
              name = "sponge";
              src = sponge;
            }
            {
              name = "colored-man-pages";
              src = colored-man-pages;
            }
            {
              name = "github-copilot-cli-fish";
              src = github-copilot-cli-fish;
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
