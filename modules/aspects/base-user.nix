# Base user bundle — aspects every user gets (deus, soumya).
# User-specific extras stay in modules/users/<name>.nix.
{ den, ... }:
{
  den.aspects.base-user = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "fish")

      # Theming
      den.aspects.appearance

      # Terminal / shell
      den.aspects.terminal

      # Editor / dev
      den.aspects.vcs
      den.aspects.editor
      den.aspects.dev-tools

      # Browser
      den.aspects.browser

      # Secrets (sops-nix HM module; the host includes the nixos half and ssh)
      den.aspects.secrets

      # Packages and tools
      den.aspects.packages
      den.aspects.shell-tools
      den.aspects.tui
      den.aspects.cli-utils
      den.aspects.apps

      # Desktop shell
      den.aspects.dms-home
    ];
  };
}
