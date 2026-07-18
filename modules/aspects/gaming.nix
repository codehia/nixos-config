{ den, ... }:
{
  den.aspects.gaming = {
    nixos = {
      programs.steam.enable = true;
      programs.steam.remotePlay.openFirewall = true;
      programs.gamemode.enable = true;
      hardware.graphics.enable32Bit = true;

      # steam-devices tags uinput "uaccess" → logind manages an ACL on /dev/uinput,
      # which freezes the plain group perms at "---" and breaks group-based access
      # (kanata). Untag it: uinput stays plain 0660 root:uinput. deus keeps Steam
      # Input virtual-gamepad access via uinput group membership instead.
      services.udev.extraRules = ''
        KERNEL=="uinput", TAG-="uaccess"
      '';
      users.users.deus.extraGroups = [ "uinput" ];
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.mangohud ];
      };

    includes = [
      (den._.unfree [
        "steam"
        "steam-original"
        "steam-unwrapped"
      ])
    ];
  };
}
