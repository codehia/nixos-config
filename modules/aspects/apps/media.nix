{
  den.aspects = {
    # Everyone
    apps.homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.kdePackages.gwenview ];
      };

    # deus only (users/deus.nix includes personal-apps)
    personal-apps.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          vlc
          # stable's ente-desktop still builds on EOL electron_41
          unstable.ente-desktop
        ];
      };
  };
}
