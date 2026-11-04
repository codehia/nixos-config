{
  den.aspects.personal-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        inkscape
        (unstable.wrapOBS {
          plugins = with unstable.obs-studio-plugins; [ obs-backgroundremoval ];
        })
      ];
    };
}
