{
  den.aspects.packages = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          vim
          wget
          git
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cowsay
          fortune
          fastfetch
          gearlever
          brightnessctl

          # file management
          xfce.thunar
          xfce.thunar-volman
          kdePackages.gwenview
        ];
      };
  };
}
