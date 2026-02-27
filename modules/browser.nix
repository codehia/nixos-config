{inputs, ...}: {
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
  };

  den.aspects.browser = {
    homeManager = {...}: {
      imports = [inputs.zen-browser.homeModules.beta];
      programs.zen-browser = {
        enable = true;
        suppressXdgMigrationWarning = true;
        profiles."Default Profile".settings = {
          "font.name.serif.x-western" = "Noto Serif";
          "font.name.sans-serif.x-western" = "SF Pro Display";
          "font.name.monospace.x-western" = "SF Mono";
          "font.size.variable.x-western" = 16;
          "font.size.fixed.x-western" = 16;
          # Indic scripts
          "font.name.sans-serif.te" = "Noto Sans Telugu";
          "font.name.serif.te" = "Noto Serif Telugu";
          "font.name.sans-serif.kn" = "Noto Sans Kannada";
          "font.name.serif.kn" = "Noto Serif Kannada";
        };
      };
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
