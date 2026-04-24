{ den, inputs, ... }:
let
  extraBrowsersConfig =
    { host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = map (name: pkgs.${name}) (host.extraBrowsers or [ ]);
        };
    };
in
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
  };

  den.aspects.browser = {
    includes = [
      (den._.unfree [
        "brave"
        "google-chrome"
      ])
      (den.lib.perUser extraBrowsersConfig)
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta ];
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = "zen-beta.desktop";
            "x-scheme-handler/http" = "zen-beta.desktop";
            "x-scheme-handler/https" = "zen-beta.desktop";
            "x-scheme-handler/about" = "zen-beta.desktop";
            "x-scheme-handler/unknown" = "zen-beta.desktop";
          };
        };
      };
  };
}
