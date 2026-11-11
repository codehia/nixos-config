# Schema — den entity kinds (hosts, users) and what applies to every entity of a kind.
#
# Per-host tunables live on the aspect that uses them (den's settings pattern):
# an aspect declares `settings.<name> = lib.mkOption { … }`, a host sets
# `settings.<aspect>.<name>`, the aspect reads `host.settings.<aspect>.<name>`.
{ lib, den, ... }:
{
  # `settings` on an aspect is structural (option declarations), not class content.
  den.reservedKeys = [ "settings" ];

  # den #694 end state: a user's own nixos content stays with the user. User → host
  # content goes through `provides.to-hosts` (delivered by mutual-provider).
  den.migrations.user-host-content.acknowledged = true;

  den.schema.host = {
    includes = [ den.batteries.mutual-provider ];

    options.settings = lib.mkOption {
      type = import ./_settings-type.nix { inherit den lib; };
      default = { };
      description = "Per-aspect typed settings (host.settings.<aspect path>.<name>).";
    };
  };

  den.schema.user = {
    # Default all users to homeManager class unless explicitly overridden.
    # CRITICAL: without it no user has the homeManager class, so home-manager.enable defaults to false.
    config.classes = lib.mkDefault [ "homeManager" ];
  };
}
