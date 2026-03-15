# Host aspect for workstation — desktop with Hyprland + DMS.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
let
  username = "soumya";
in
{
  den.aspects.workstation = {
    nixos =
      { pkgs, ... }:
      let
        tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
        session = "/home/${username}/.nix-profile/bin/start-hyprland";
      in
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        networking = {
          hostName = "workstation";
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
        ];

        programs = {
          fish.enable = true;
        };

        services = {
          kanata = {
            enable = false;
            keyboards = {
              kinesis = {
                devices = [
                  "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
                  "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
                ];
                extraDefCfg = "process-unmapped-keys yes";
                configFile = ../thinkpad/kinesis.kbd;
              };
            };
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
          gvfs.enable = true;
          tailscale = {
            enable = true;
            package = pkgs.unstable.tailscale;
            openFirewall = true;
            port = 7498;
          };
          pipewire = {
            enable = true;
            pulse.enable = true;
          };
          udev.extraRules = ''
            KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
          '';
        };

        hardware = {
          uinput.enable = true;
          bluetooth = {
            enable = false;
            powerOnBoot = false;
            settings = {
              General = {
                Experimental = false;
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

        systemd.services.kanata-internalKeyboard.serviceConfig = {
          SupplementaryGroups = [
            "input"
            "uinput"
          ];
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
      den.aspects.hyprland
      (den.aspects.dms { inherit username; })
      den.aspects.git
      den.aspects.lazygit
      (den.aspects.nvim {
        languages = [
          "lua"
          "nix"
          "python"
        ];
      })
      den.aspects.direnv
      den.aspects.browser
      den.aspects.secrets
      (den.aspects.ssh {
        sopsFile = ../../../secrets/workstation.yaml;
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
      den.aspects.work
      den.aspects.cursor
      den.aspects.disko
      den.aspects.gnome-keyring
    ];
  };
}
