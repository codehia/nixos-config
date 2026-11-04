# Steam + gamemode. A user aspect, pulled in per host via host.extraAspects, so
# `user.extraGroups` lands on the user who games; the nixos block goes to the host.
{ den, ... }:
{
  den.aspects.gaming = {
    nixos = {
      programs.steam.enable = true;
      programs.steam.remotePlay.openFirewall = true;
      programs.gamemode.enable = true;
      hardware.graphics.enable32Bit = true;

      # Creates the `uinput` group and makes /dev/uinput 0660 root:uinput.
      hardware.uinput.enable = true;

      # steam-devices tags uinput "uaccess" → logind manages an ACL on /dev/uinput,
      # which freezes the plain group perms at "---" and breaks group-based access
      # (kanata). Untag it: uinput stays plain 0660 root:uinput. The gaming user keeps
      # Steam Input virtual-gamepad access via uinput group membership instead.
      services.udev.extraRules = ''
        KERNEL=="uinput", TAG-="uaccess"
      '';
    };

    user.extraGroups = [ "uinput" ];

    includes = [
      (den._.unfree [
        "steam"
        "steam-original"
        "steam-unwrapped"
      ])
    ];
  };
}
