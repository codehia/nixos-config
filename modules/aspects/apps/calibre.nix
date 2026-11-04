{
  den.aspects.personal-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.calibre ];
    };
}
