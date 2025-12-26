# modules/nixos/common.nix
# Shared NixOS configuration for all hosts
{
  flake,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  # Common allowed unfree packages
  allowedUnfree = [
    "1password"
    "1password-cli"
    "1password-gui"
    "slack"
    "spotify"
    "spotify-unwrapped"
    "zoom"
    "zoom-us"
    "discord"
    "vscode"
    "obsidian"
    "mullvad"
    "mullvad-vpn"
    "brave"
    "signal-desktop"
  ];

  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet"; # TODO: rename to pkgs.tuigreet when nixpkgs updates
  username = "deus";
in
{
  options.machine = {
    gcDays = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Number of days after which garbage collection deletes old generations";
    };
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this machine is a laptop (enables TLP, touchpad, etc.)";
    };
  };

  config = {
    # Nixpkgs configuration
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfree;
    };

    # Home-manager integration
    home-manager = {
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {
        inherit inputs self;
        hostname = config.networking.hostName;
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit (pkgs) system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfree;
          };
        };
      };
      users.${username} = {
        imports = [ (self + /configurations/home/${username}.nix) ];
      };
    };

    # Nix settings
    nix = {
      optimise = {
        automatic = true;
        dates = [ "03:45" ];
      };
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        trusted-users = [
          "root"
          username
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than ${toString config.machine.gcDays}d";
      };
    };

    # Boot configuration
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      plymouth = {
        enable = true;
        theme = "connect";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "connect" ];
          })
        ];
      };
      initrd = {
        verbose = false;
        systemd.enable = true;
        kernelModules = [ "amdgpu" ];
      };
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_level=3"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
      kernelModules = [ "uinput" ];
      consoleLogLevel = 0;
    };

    # Locale
    time.timeZone = "Asia/Kolkata";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocales = [ "all" ];
    };

    # Security
    security = {
      sudo.wheelNeedsPassword = false;
      pam.services = {
        greetd.enableGnomeKeyring = true;
        greetd-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
    };

    # Users
    users.users.${username} = {
      isNormalUser = true;
      description = "Soumyaranjan Acharya";
      initialPassword = "Soumya$321";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.fish;
    };

    # Common system packages
    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      fish
    ];

    # Programs
    programs = {
      fish.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };

    # Networking (hostname set per-host)
    networking.networkmanager.enable = true;

    # Common services
    services = {
      greetd = {
        enable = true;
        settings =
          let
            session = "/etc/profiles/per-user/${username}/bin/Hyprland";
          in
          {
            initial_session = {
              command = "${session}";
              user = "${username}";
            };
            default_session = {
              command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time -cmd ${session}";
              user = "greeter";
            };
          };
      };
      gvfs.enable = true;
      tailscale.enable = true;
      openssh.enable = true;
      pipewire = {
        enable = true;
        pulse.enable = true;
      };
      udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';
    };

    # Hardware
    hardware = {
      uinput.enable = true;
      bluetooth = {
        enable = true;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa
          rocmPackages.clr.icd
        ];
      };
    };

    system.stateVersion = "25.05";
  };
}
