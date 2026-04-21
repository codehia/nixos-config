# User aspect — defines the "soumya" user identity and selects feature aspects.
# Soumya is the primary user on workstation and a secondary user on thinkpad.
# WM is hardcoded to hyprland (consistent across all hosts).
{ den, ... }:
{
  den.aspects.soumya = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")

      # Theming
      den.aspects.appearance

      # Terminal / shell
      den.aspects.terminal

      # Window manager — hardcoded to hyprland across all hosts
      den.aspects.hyprland

      # Editor / dev
      den.aspects.vcs
      den.aspects.editor

      # Browser
      den.aspects.browser

      # Secrets / SSH
      den.aspects.secrets
      den.aspects.ssh

      # Packages and tools
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.packages
      den.aspects.dev-tools
      den.aspects.apps

      # Work
      den.aspects.work

      # Desktop shell
      den.aspects.dms-home
    ];

    nixos =
      { config, ... }:
      {
        sops.secrets.soumya_password = {
          sopsFile = ../../secrets/soumya.yaml;
          key = "user_password";
          neededForUsers = true;
        };
        users.users.soumya = {
          description = "Soumyaranjan Acharya";
          hashedPasswordFile = config.sops.secrets.soumya_password.path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIv1y8DzCwaUGK6DO+64qjctEC1Aia0LW/jhLhrYGSUB soumya@workstation"
          ];
        };
      };

    homeManager.home = {
      homeDirectory = "/home/soumya";
    };
    homeManager.programs.git.settings.user = {
      name = "Soumyaranjan Acharya";
      email = "";
    };
  };
}
