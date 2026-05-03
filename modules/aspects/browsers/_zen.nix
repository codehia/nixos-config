{ inputs }:
{
  flakeInput = {
    url = "github:0xc000022070/zen-browser-flake";
  };
  package = pkgs: inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
  mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
    };
  };
}
