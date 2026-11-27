{
  den.aspects.personal-apps.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.calibre ];
      # Hide unused calibre launchers. E-book viewer stays: it is the ebook MIME default.
      xdg.desktopEntries = {
        calibre-ebook-edit = {
          name = "E-book editor";
          noDisplay = true;
        };
        calibre-lrfviewer = {
          name = "LRF viewer";
          noDisplay = true;
        };
      };
    };
}
