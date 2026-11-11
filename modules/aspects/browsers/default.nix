{ den, lib, ... }:
let
  extraBrowsersConfig =
    { host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = map (name: pkgs.${name}) host.settings.browser.extra;
        };
    };
  zen = import ./_zen.nix;
  helium = import ./_helium.nix;

  # settings.browser.default picks the mimeApps, $BROWSER and the
  # `default-browser` launcher the WM binds call.
  defaultBrowserConfig =
    { host, ... }:
    let
      browser = { inherit zen helium; }.${host.settings.browser.default};
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
    settings = {
      default = lib.mkOption {
        type = lib.types.enum [
          "zen"
          "helium"
        ];
        default = "zen";
        description = "Default browser (mimeApps, $BROWSER, WM launch bind); see _<name>.nix.";
      };
      extra = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra nixpkgs browser attrs installed for users on this host.";
      };
    };

    includes = [
      (den.batteries.unfree [ "google-chrome" ])
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
