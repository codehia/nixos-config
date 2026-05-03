{ inputs }:
{
  flakeInput = {
    url = "github:AlvaroParker/helium-nix";
  };
  package = pkgs: inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
  mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
    };
  };

}
