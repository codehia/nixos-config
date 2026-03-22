# User aspect — defines the "soumya" user identity and selects feature aspects.
# Soumya is the primary user on workstation and a secondary user on thinkpad.
# WM is hardcoded to hyprland (consistent across all her hosts).
{ den, ... }:
{
  den.aspects.soumya = {
    includes = [
      den._.primary-user
      (den._.user-shell "fish")

      # Theming
      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fonts
      den.aspects.cursor

      # Terminal / shell
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

      # User-level services
      den.aspects.gnome-keyring
    ];

    nixos.users.users.soumya = {
      description = "Soumyaranjan Acharya";
      initialPassword = "Soumya$321";
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
