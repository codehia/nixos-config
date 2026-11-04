# Personal apps gate — users with `personalApps = true` (schema.nix) get
# den.aspects.personal-apps. Each app file (calibre, chat, creative, media)
# contributes its packages to that aspect (collector pattern).
{ den, lib, ... }:
let
  personalApps =
    { user, ... }:
    lib.optionalAttrs user.personalApps {
      includes = [ den.aspects.personal-apps ];
    };
in
{
  den.aspects.apps.includes = [ personalApps ];
}
