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

  # host.defaultBrowser (schema.nix) picks the mimeApps, $BROWSER and the
  # `default-browser` launcher the WM binds call.
  defaultBrowserConfig =
    { host, ... }:
    let
      browser = { inherit zen helium; }.${host.defaultBrowser};
    in
    {
      homeManager =
        { pkgs, ... }:
        {
          xdg.mimeApps = browser.mimeApps;
          home.sessionVariables.BROWSER = browser.command;
          home.packages = [
            (pkgs.writeShellScriptBin "default-browser" ''exec ${browser.command} "$@"'')
          ];
        };
    };
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
      defaultBrowserConfig
    ];

    homeManager =
      { inputs', ... }:
      {
        home.packages = [
          (zen.package inputs')
          (helium.package inputs')
        ];
      };
  };
}
