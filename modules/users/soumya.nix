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
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.cursor

      # Terminal / shell
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.kitty
      den.aspects.tmux

      # Window manager — hardcoded to hyprland across all hosts
      den.aspects.hyprland

      # Editor / dev
      den.aspects.git
      den.aspects.lazygit
      den.aspects.nvim
      den.aspects.direnv

      # Browser
      den.aspects.browser

      # Secrets / SSH
      den.aspects.secrets
      den.aspects.ssh

      # Packages and tools
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.productivity

      # Work
      den.aspects.work
      den.aspects.zoom

      # Desktop shell
      den.aspects.dms-home
    ];

    nixos.users.users.soumya = {
      description = "Soumyaranjan Acharya";
      initialPassword = "REDACTED";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB15hq8HqBbgw3PspZ6O0iegrqMbqahPj0udLuf2eZ9f soumya@flockjay.com"
      ];
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
