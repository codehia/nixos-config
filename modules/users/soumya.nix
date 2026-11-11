# User aspect — defines the "soumya" user identity and selects feature aspects.
# Soumya is the primary user on workstation and a secondary user on thinkpad.
# The login password secret is set per user on the host side (secrets.nix).
{ den, ... }:
{
  den.aspects.soumya = {
    includes = [
      den.aspects.base-user
      den.aspects.work
    ];

    user = {
      description = "Soumyaranjan Acharya";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv1y8DzCwaUGK6DO+64qjctEC1Aia0LW/jhLhrYGSUB soumya@workstation"
      ];
    };

    homeManager.programs.git.settings.user = {
      name = "Soumyaranjan Acharya";
      email = "";
    };
  };
}
