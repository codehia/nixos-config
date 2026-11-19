{
  den.aspects.tailscale = {
    nixos =
      { pkgs, ... }:
      {
        services.tailscale = {
          enable = true;
          package = pkgs.unstable.tailscale;
          openFirewall = true;
          extraSetFlags = [ "--operator=deus" ];
        };
        networking.firewall = {
          trustedInterfaces = [ "tailscale0" ];
          checkReversePath = "loose";
        };
      };

    # Tray icon at login via XDG autostart: runs with the session environment,
    # so "More settings" can open the browser (tailscale/tailscale#17656).
    # deus only: the tray needs the operator user set above.
    provides.deus.homeManager =
      { pkgs, osConfig, ... }:
      let
        tray = pkgs.makeDesktopItem {
          name = "tailscale-systray";
          desktopName = "Tailscale tray";
          exec = "${osConfig.services.tailscale.package}/bin/tailscale systray";
        };
      in
      {
        xdg.autostart = {
          enable = true;
          entries = [ "${tray}/share/applications/tailscale-systray.desktop" ];
        };
      };
  };
}
