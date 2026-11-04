{ den, ... }:
let
  extraBrowsersConfig =
    { host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = map (name: pkgs.${name}) host.extraBrowsers;
        };
    };
  zen = import ./_zen.nix;
  helium = import ./_helium.nix;
in
{
  flake-file.inputs = {
    zen-browser = zen.flakeInput;
    helium = helium.flakeInput;
  };

  den.aspects.browser = {
    includes = [
      (den._.unfree [
        "brave"
        "google-chrome"
        "firefox-esr"
      ])
      extraBrowsersConfig
    ];

    homeManager =
      { inputs', ... }:
      {
        home.packages = [
          (zen.package inputs')
          (helium.package inputs')
        ];
        xdg.mimeApps = zen.mimeApps;
      };
  };
}
