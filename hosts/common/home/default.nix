{ pkgs, lib, ... }: {
  imports = [
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
    kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      settings = [
        {
          profile = {
            name = "undocked";
            outputs = [{
              criteria = "eDP-1";
              mode = "1920x1080@60.03300";
              scale = 1.0;
              position = "0,0";
              status = "enable";
            }];
          };
        }
        {
          profile = {
            name = "azanDocked";
            outputs = [
              {
                criteria = "BNQ BenQ GW2480 BCP0111201Q";
                mode = "1920x1080@60.00Hz";
              }
              {
                criteria = "eDP-1";
                status = "disable";
              }
            ];
          };
        }
        {
          profile = {
            name = "miniDocked";
            outputs = [
              {
                criteria = "Samsung Electric Company LF24T35 HNAR101094";
                mode = "1920x1080@74.97300";
              }
              {
                criteria = "eDP-1";
                status = "disable";
              }
            ];
          };
        }
        {
          profile = {
            name = "docked";
            outputs = [
              {
                criteria = "LG Electronics LG HDR WQHD 0x0001991D";
                mode = "3440x1440@75.05Hz";
              }
              {
                criteria = "eDP-1";
                status = "disable";
              }
            ];
          };

        }
      ];
    };
    dunst.enable = true;
    hyprsunset = {
      enable = true;
      transitions = {
        sunrise = {
          calendar = "*-*-* 06:00:00";
          requests = [ [ "temperature" "6500" ] [ "gamma 100" ] ];
        };
        sunset = {
          calendar = "*-*-* 19:00:00";
          requests = [[ "temperature" "3000" ]];
        };
      };
    };
  };
  home = {
    username = "deus";
    homeDirectory = "/home/deus";
    pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 35;
      gtk.enable = true;
    };
    # Packages that should be installed to the user profile.
    packages = with pkgs; [
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

      ghostty # terminal emulator
      kitty
      wofi

      fish
      xfce.thunar
      xfce.thunar-volman
      nixfmt-classic
      just
      devenv

      # SECRETS
      age
      ssh-to-age

      slack
      brave
      vlc

      qbittorrent
      brightnessctl
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
      zoom-us

      libreoffice-still

      telegram-desktop
      signal-desktop-bin

      httpie-desktop
    ];
    stateVersion = "25.05";
  };
  catppuccin = {
    flavor = "mocha";
    enable = true;
    starship.enable = true;
    fish.enable = true;
    fzf.enable = true;
    kitty.enable = true;
    ghostty.enable = true;
    nvim.enable = true;
    hyprland.enable = true;
    rofi.enable = true;
    tmux.enable = true;
    lazygit.enable = true;
  };

  programs = {
    gh.enable = true;
    direnv = {
      enable = true;
      # enableFishIntegration = lib.mkForce true;
      nix-direnv.enable = true;
    };
    zen-browser.enable = true;
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
      ];
      functions = {
        fish_command_not_found = {
          body = "__fish_default_command_not_found_handler $argv[1]";
        };
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        directory.style = "blue";
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$python"
          "$character"
        ];
        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";

        };
        git_branch = {
          format = "[$branch]($style)";
          # style = "bright-black";
          symbol = "󰊢 ";
          style = "bold mauve";
        };
        git_status = {
          format =
            "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        git_state = {
          format = "([$state( $progress_current/$progress_total)]($style)) ";
          style = "bright-black";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };

        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
      };
    };
  };
}
