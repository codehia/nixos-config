# Host aspect for workstation — desktop with Hyprland + DMS.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
let
  username = "soumya";
  session = "/home/${username}/.nix-profile/bin/start-hyprland";
in
{
  den.aspects.workstation = {
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        time.timeZone = "Asia/Kolkata";

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocales = [ "all" ];
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
          gvfs.enable = true;
          tailscale = {
            enable = true;
            package = pkgs.unstable.tailscale;
            openFirewall = true;
            port = 7498;
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
            settings.General.Experimental = false;
          };
          graphics.extraPackages = with pkgs; [
            rocmPackages.clr.icd
          ];
        };

        systemd.services.kanata-internalKeyboard.serviceConfig = {
          SupplementaryGroups = [
            "input"
            "uinput"
          ];
        };
      };

    includes = [
      (den.aspects.nix-config { inherit username; })
      (den.aspects.networking { hostname = "workstation"; })
      (den.aspects.greetd { inherit username session; })
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.sudo
      den.aspects.dconf
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
