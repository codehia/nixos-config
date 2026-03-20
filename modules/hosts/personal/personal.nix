# Host aspect for personal — desktop NixOS system configuration.
# The `includes` list at the bottom composes all feature aspects into this host.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.aspects.personal = {
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ./_hardware-configuration.nix
          ./_disko-config.nix
        ];

        boot.initrd.kernelModules = [ "amdgpu" ];

        time.timeZone = "Asia/Kolkata";

        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocales = [ "all" ];
        };

        environment.systemPackages = with pkgs; [
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
        ];

        programs.appimage.enable = true;

        services = {
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
        };
      };

    includes = [
      den.aspects.nix-config
      den.aspects.networking
      den.aspects.greetd
      den.aspects.nh
      den.aspects.nix-tools
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.lact
      den.aspects.ios-devices
      den.aspects.zram
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
      den.aspects.swayfx
      den.aspects.dms
      den.aspects.git
      den.aspects.lazygit
      den.aspects.nvim
      den.aspects.direnv
      den.aspects.browser
      den.aspects.secrets
      den.aspects.ssh
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
