# Global defaults — config applied to every host and user.
# den.default sets baseline NixOS and home-manager options across all hosts.
{
  den,
  lib,
  ...
}:
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
    # Prevent dbus-broker reload race during activation (polkit/accounts-daemon
    # restart in parallel; reload fails with exit 4 — fall back to restart instead).
    nixos.systemd.services.dbus.reloadIfChanged = lib.mkForce false;
    includes = [
      den.provides.define-user
      den.provides.hostname
      den.provides.inputs'
    ];
  };

  # Enable mutual-provider at the user context so provides.to-users /
  # provides.to-hosts routing works across host <-> user boundaries.
  den.ctx.user.includes = [ den.provides.mutual-provider ];
}
