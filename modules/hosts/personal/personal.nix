# Host aspect for personal — desktop NixOS system configuration.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
let
  username = "deus";
in
{
  den.aspects.personal = {
    nixos =
      { pkgs, ... }:
      let
        tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
        session = "/home/${username}/.nix-profile/bin/sway";
      in
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        boot.initrd.kernelModules = [ "amdgpu" ];

        zramSwap = {
          enable = true;
          priority = 100;
          algorithm = "lz4";
          memoryPercent = 50;
        };

        networking = {
          hostName = "personal";
          networkmanager.enable = true;
          firewall = {
            trustedInterfaces = [ "tailscale0" ];
            checkReversePath = "loose";
          };
        };

        time.timeZone = "Asia/Kolkata";

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocales = [ "all" ];
        };

        security.sudo.wheelNeedsPassword = false;

        environment.systemPackages = with pkgs; [
          vim
          wget
          git
          fish
          libimobiledevice
          ifuse
          idevicerestore
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
        ];

        programs = {
          dconf.enable = true;
          appimage.enable = true;
          fish.enable = true;
        };

        services = {
          usbmuxd.enable = true;
          flatpak.enable = true;
          gvfs.enable = true;
          tailscale.enable = true;
          mullvad-vpn = {
            enable = true;
            package = pkgs.mullvad-vpn;
          };
          avahi = {
            enable = true;
            nssmdns4 = true;
            nssmdns6 = true;
            openFirewall = true;
          };
          greetd = {
            enable = true;
            settings = {
              initial_session = {
                command = "${session}";
                user = "${username}";
              };
              default_session = {
                command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --cmd '${session}'";
                user = "greeter";
              };
            };
          };
          pipewire = {
            enable = true;
            pulse.enable = true;
            alsa = {
              enable = true;
              support32Bit = true;
            };
          };
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [ mesa ];
        };
      };

    includes = [
      (den.aspects.nix-config username)
      den.aspects.boot
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fonts
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.kitty
      den.aspects.tmux
      den.aspects.swayfx
      (den.aspects.dms username)
      den.aspects.git
      den.aspects.lazygit
      (den.aspects.nvim {
        languages = [
          "lua"
          "nix"
          "python"
          "typescript"
          "go"
          "latex"
        ];
      })
      den.aspects.direnv
      den.aspects.browser
      den.aspects.secrets
      (den.aspects.ssh {
        sopsFile = ../../../secrets/personal.yaml;
        userSopsFile = ../../../secrets/deus.yaml;
      })
      den.aspects.packages
      den.aspects.services
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.dev-tools
      den.aspects.productivity
      den.aspects.media
      den.aspects.creative
      den.aspects.chat
      den.aspects.cursor
      den.aspects.disko
      den.aspects.rclone
      den.aspects.gnome-keyring
    ];
  };
}
