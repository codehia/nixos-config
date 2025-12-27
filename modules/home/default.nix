{
  pkgs,
  pkgs-unstable,
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.zen-browser.homeModules.beta
    inputs.sops-nix.homeManagerModules.sops
    inputs.stylix.homeModules.stylix
    ./stylix.nix
    ./hyprland
    ./waybar
    ./ghostty.nix
    ./kitty.nix
    ./rofi.nix
    ./tmux.nix
    ./lazygit.nix
    ./git.nix
    ./nvim
  ];

  services = {
    gnome-keyring.enable = true;
    # kanshi is configured per-host in modules/home/{thinkpad,workstation}.nix
    dunst.enable = true;
    hyprsunset = {
      enable = true;
      settings = {
        profile = [
          {
            time = "6:00";
            identity = true;
          }
          {
            time = "18:30";
            temperature = 3000;
            gamma = 0.6;
          }

        ];
      };
    };
  };
  home = {
    pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 35;
      gtk.enable = true;
    };
    # Packages that should be installed to the user profile.
    packages =
      (with pkgs; [
        cowsay
        fortune
        # archives
        zip
        xz
        unzip
        p7zip

        # utils
        ripgrep # recursively searches directories for a regex pattern
        jq # A lightweight and flexible command-line JSON processor
        yq-go # yaml processor https://github.com/mikefarah/yq
        eza # A modern replacement for ‘ls’
        fzf # A command-line fuzzy finder

        # networking tools
        mtr # A network diagnostic tool
        iperf3
        dnsutils # `dig` + `nslookup`
        ldns # replacement of `dig`, it provide the command `drill`
        aria2 # A lightweight multi-protocol & multi-source command-line download utility
        socat # replacement of openbsd-netcat
        nmap # A utility for network discovery and security auditing
        ipcalc # it is a calculator for the IPv4/v6 addresses

        # misc
        cowsay
        file
        which
        tree
        gnused
        gnutar
        gawk
        zstd
        gnupg

        # nix related
        #
        # it provides the command `nom` works just like `nix`
        # with more details log output
        nix-output-monitor

        # productivity
        hugo # static site generator
        glow # markdown previewer in terminal

        htop
        btop # replacement of htop/nmon
        iotop # io monitoring
        iftop # network monitoring

        # system cal?l monitoring
        strace # system call monitoring
        ltrace # library call monitoring
        lsof # list open files

        # system tools
        sysstat
        lm_sensors # for `sensors` command
        ethtool
        pciutils # lspci
        usbutils # lsusb

        kitty

        fish
        xfce.thunar
        xfce.thunar-volman
        nixfmt-classic
        just

        # SECRETS
        age
        ssh-to-age

        brave
        vlc

        fastfetch
        ente-auth
        _1password-gui
        _1password-cli

        pulsemixer
        bluetui
        spotify
        ncdu

        libglvnd
        libglibutil

        libreoffice-still

        httpie-desktop
        obs-studio

        calibre
        unrar
      ])
      ++ (with pkgs-unstable; [
        ghostty
        devenv
        vscode
        gearlever
      ]);
  };
  catppuccin = {
    flavor = "mocha";
    enable = true;
    fish.enable = true;
    fzf.enable = true;
    kitty.enable = true;
    ghostty.enable = true;
    nvim.enable = true;
    hyprland.enable = true;
    lazygit.enable = true;
    rofi.enable = false;
    tmux.enable = false;
  };

  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
        gh-poi
        gh-f
      ];
    };
    zen-browser.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    fzf = {
      enable = true;
      # custom settings
      enableFishIntegration = true;
      tmux.enableShellIntegration = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    fish = {
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
        # Add fish aliases here if needed
        ll = "eza -l";
        la = "eza -la";
        lt = "eza --tree";
        fbf = "tmuxp load fj";
      };
      plugins = with pkgs.fishPlugins; [
        {
          name = "pure";
          src = pure.src;
        }
        {
          name = "plugin-git";
          src = plugin-git.src;
        }
        {
          name = "fzf-fish";
          src = fzf-fish.src;
        }
        {
          name = "git-abbr";
          src = git-abbr.src;
        }
        {
          name = "plugin-sudope";
          src = plugin-sudope.src;
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
        # col
      ];
      functions = {
        fish_command_not_found = {
          body = "__fish_default_command_not_found_handler $argv[1]";
        };
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      };
    };
  };
}
