# Personal host — aspect definition + host declaration.
# Hardware and disko configs are _-prefixed (excluded from import-tree) and imported explicitly.
{ den, ... }:
{
  den.hosts.x86_64-linux.personal = {
    home-manager.enable = true;
    gpuKey = "1002:7340-1043:04E6-0000:2d:00.0";
    nhCleanEnabled = true;
    greetdUser = "deus";
    greetdSessionBin = "sway";
    wm = "swayfx";
    extraAspects = [ "qbittorrent" ];
    nvimLanguages = [
      "lua"
      "nix"
      "python"
      "typescript"
      "go"
      "latex"
    ];
    users.deus = { };
    # Temporary: soumya added for multi-user DMS testing — remove after fix confirmed
    users.soumya = {
      nvimLanguages = [
        "nix"
        "lua"
        "python"
        "typescript"
      ];
    };
  };

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
      den.aspects.lact
      den.aspects.ios-devices
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
