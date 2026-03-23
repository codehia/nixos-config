# Workstation host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.workstation = {
    home-manager.enable = true;
    nhCleanEnabled = true;
    greetdUser = "soumya";
    greetdSessionBin = "start-hyprland";
    wm = "hyprland";
    # Aspects added here are picked up by deus's extraAspectsSelector and included only on this host.
    # Useful when deus needs an aspect on some hosts but not all (e.g. work tools on a work laptop).
    extraAspects = [ ];
    nvimLanguages = [
      "lua"
      "nix"
      "python"
    ];
    users.deus = { };
    users.soumya = {
      nvimLanguages = [
        "nix"
        "lua"
        "python"
        "typescript"
      ];
    };
  };

  den.aspects.workstation = {
    nixos =
      { ... }:
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
        };

        systemd.services.kanata-internalKeyboard.serviceConfig = {
          SupplementaryGroups = [
            "input"
            "uinput"
          ];
        };
      };

    includes = [
      # Core system
      den.aspects.nix-config
      den.aspects.networking
      den.aspects.boot
      den.aspects.sudo
      den.aspects.disko

      # Nix tooling
      den.aspects.nh
      den.aspects.nix-tools

      # Hardware
      den.aspects.tailscale
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.zram

      # Desktop
      den.aspects.dms
      den.aspects.greetd
      den.aspects.dconf
      den.aspects.fonts
      den.aspects.gnome-keyring
    ];
  };
}
