# Schema — shared metadata modules applied to all hosts, users, and homes.
#
# den.schema.conf:  Applied to every host, user, and home.
# den.schema.user:  Applied to every user (imports conf).
{
  # Default all users to homeManager class unless explicitly overridden.
  # CRITICAL: without this, den.ctx.hm-host never activates.
  den.schema.user =
    { lib, ... }:
    {
      config.classes = lib.mkDefault [ "homeManager" ];
    };
}
