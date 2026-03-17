_: {
  den.aspects.media = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          vlc
          spotify
        ];
      };
  };
}
