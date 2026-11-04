{
  # Everyone
  den.aspects.apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kdePackages.gwenview ];
    };

  # personalApps users only
  den.aspects.personal-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vlc
        # stable's ente-desktop still builds on EOL electron_41
        unstable.ente-desktop
      ];
    };
}
