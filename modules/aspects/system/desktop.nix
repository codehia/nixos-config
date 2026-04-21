# Graphical session bundle — aspects required for graphical desktop hosts.
{ den, ... }:
{
  den.aspects.graphical-session = {
    includes = [
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.greetd
      den.aspects.dms
      den.aspects.fonts
      den.aspects.gnome-keyring
      den.aspects.core-services
      den.aspects.dconf
    ];
  };
}
