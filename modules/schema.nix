# Schema — typed metadata for den entities (hosts, users, homes).
#
# den.schema.host:  options every host declaration (den.hosts.<system>.<name>) accepts.
# den.schema.user:  options every user declaration (host.users.<name>) accepts.
# Aspects read these as host.<opt> / user.<opt>. Hosts stay freeform, so attrs not
# declared here (e.g. greetdSessionBin/greetdSessionCmd) are read with `or`.
{ lib, ... }:
{
  den.schema.host =
    { lib, ... }:
    {
      options = {
        isLaptop = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Laptop host: battery widgets, DMS battery plugin, charge toggle.";
        };
        extraAspects = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Aspect names deus gets on this host only (users/deus.nix).";
        };
        extraBrowsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra nixpkgs browser attrs installed for users on this host.";
        };
        gpuKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "LACT GPU key (sudo lact cli list) for the fan curve in lact.nix.";
        };
        nhCleanEnabled = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "GC via nh clean (true) or the built-in nix.gc timer (false). Exactly one runs.";
        };
        greetdUser = lib.mkOption {
          type = lib.types.str;
          description = "User greetd auto-logs into on boot.";
        };
      };
    };

  den.schema.user = {
    # Default all users to homeManager class unless explicitly overridden.
    # CRITICAL: without this, den.ctx.hm-host never activates.
    config.classes = lib.mkDefault [ "homeManager" ];

    options.personalApps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install personal apps (chat, media, calibre, creative).";
    };
  };
}
