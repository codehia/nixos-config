{
  den.aspects.packages = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          vim
          wget
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cowsay
          fortune
        ];
        # vim stays as a terminal fallback; hide its launcher entries.
        xdg.desktopEntries = {
          gvim = {
            name = "GVim";
            noDisplay = true;
          };
          vim = {
            name = "Vim";
            noDisplay = true;
          };
        };
      };
  };
}
