# Desktop host bundle — what every graphical host includes.
# A future server host would include den.aspects.base-system alone.
{ den, ... }:
{
  den.aspects.desktop-host = {
    includes = [
      den.aspects.base-system
      den.aspects.graphical-session
      den.aspects.tailscale
      den.aspects.desktop-services
      den.aspects.dev-tools # docker; users include it for the homeManager half
    ];
  };
}
