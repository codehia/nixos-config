# User aspect — defines the "deus" user identity and selects all feature aspects.
#
# Feature aspects live here so their homeManager config flows to deus's home.
# Host-specific additions live in den.aspects."deus@<host>" (hosts/<host>/default.nix).
# The login password secret is set per user on the host side (secrets.nix).
{ den, ... }:
{
  den.aspects.deus = {
    includes = [
      den.aspects.base-user
      den.aspects.personal-apps
      den.aspects.zoom
      den.aspects.qbittorrent
    ];

    user = {
      description = "Soumyaranjan Acharya";
      extraGroups = [ "video" ]; # direct backlight write (brightnessctl udev rule)
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8QcSgwXXrWmVdjcDcKZbBPkQWybWAZih/8YjFno+cK dev@sacharya.dev"
      ];
    };

    homeManager.programs.git.settings.user = {
      name = "codehia";
      email = "dev@sacharya.dev";
    };
  };
}
