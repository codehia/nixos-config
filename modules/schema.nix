# Schema — shared metadata modules applied to all hosts, users, and homes.
#
# den.schema.conf:  Applied to every host, user, and home.
# den.schema.user:  Applied to every user (imports conf).
{ inputs, lib, ... }:
let
  unstableOverlay = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
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
