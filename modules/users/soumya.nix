# User aspect — defines the "soumya" user identity and selects feature aspects.
# Soumya is the primary user on workstation and a secondary user on thinkpad.
# WM is hardcoded to swayfx (consistent across all hosts).
{ den, ... }:
{
  den.aspects.soumya = {
    includes = [
      den.aspects.base-user
      den.aspects.work
    ];

    nixos.sops.secrets.soumya_password = {
      sopsFile = ../../secrets/soumya.yaml;
      key = "user_password";
      neededForUsers = true;
    };

    user =
      { osConfig, ... }:
      {
        description = "Soumyaranjan Acharya";
        hashedPasswordFile = osConfig.sops.secrets.soumya_password.path;
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
