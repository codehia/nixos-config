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
  zen = import ./_zen.nix { inherit inputs; };
  helium = import ./_helium.nix { inherit inputs; };
in
{
  flake-file.inputs.zen-browser = zen.flakeInput;
  flake-file.inputs.helium = helium.flakeInput;

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
        home.packages = [
          (zen.package pkgs)
          (helium.package pkgs)
        ];
        xdg.mimeApps = zen.mimeApps;
      };
  };
}
