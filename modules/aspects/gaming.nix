# Steam + gamemode. A user aspect, included per host via den.aspects."<user>@<host>", so
# `user.extraGroups` lands on the user who games; provides.to-hosts carries the system part.
{ den, ... }:
{
  den.aspects.gaming = {
    provides.to-hosts.nixos = {
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
      (den.batteries.unfree [
        "steam"
        "steam-unwrapped"
      ])
    ];
  };
}
