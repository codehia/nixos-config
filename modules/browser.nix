{ inputs, ... }:
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
  };

  den.aspects.browser = {
    homeManager =
      { ... }:
      {
        imports = [ inputs.zen-browser.homeModules.beta ];
        programs.zen-browser.enable = true;
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "zen.desktop";
            "x-scheme-handler/http" = "zen.desktop";
            "x-scheme-handler/https" = "zen.desktop";
            "x-scheme-handler/about" = "zen.desktop";
            "x-scheme-handler/unknown" = "zen.desktop";
          };
        };
      };
  };
}
