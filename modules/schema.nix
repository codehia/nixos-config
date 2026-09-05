# Schema — shared metadata modules applied to all hosts, users, and homes.
#
# den.schema.conf:  Applied to every host, user, and home.
# den.schema.user:  Applied to every user (imports conf).
{ inputs, lib, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        # beekeeper-studio bundles an EOL Electron. Allowed by name (not by
        # pinned version) so it survives version bumps.
        allowInsecurePredicate = pkg: lib.getName pkg == "beekeeper-studio";
      };
    };
  };
in
{
  # Apply the unstable overlay to ALL nixpkgs instances (host, user, home).
  den.schema.conf = {
    nixpkgs.overlays = [ unstableOverlay ];
  };

  # Default all users to homeManager class unless explicitly overridden.
  # CRITICAL: without this, den.ctx.hm-host never activates.
  den.schema.user =
    { lib, ... }:
    {
      config.classes = lib.mkDefault [ "homeManager" ];
    };
}
