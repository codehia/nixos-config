{ inputs, ... }:
{
  flake-file.inputs.apple-fonts = {
    url = "github:Lyndeno/apple-fonts.nix";
  };

  den.aspects.fonts = {
    nixos =
      { pkgs, ... }:
      {
        fonts = {
          fontconfig = {
            enable = true;
            antialias = true;
            hinting = {
              enable = true;
              style = "slight";
            };
            subpixel = {
              rgba = "rgb";
              lcdfilter = "default";
            };
            localConf = ''
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
              <fontconfig>
                <!-- Sans-serif: Use SF Pro (macOS default UI font) -->
                <alias>
                  <family>sans-serif</family>
                  <prefer>
                    <family>SF Pro</family>
                    <family>Noto Sans CJK</family>
                    <family>Symbols Nerd Font</family>
                  </prefer>
                </alias>

                <!-- Serif: Use New York (macOS serif font) -->
                <alias>
                  <family>serif</family>
                  <prefer>
                    <family>New York</family>
                    <family>Noto Serif CJK</family>
                    <family>Symbols Nerd Font</family>
                  </prefer>
                </alias>

                <!-- Monospace: JetBrains Mono with SF Mono fallback -->
                <alias>
                  <family>monospace</family>
                  <prefer>
                    <family>JetBrainsMono Nerd Font</family>
                    <family>SF Mono</family>
                    <family>Symbols Nerd Font</family>
                  </prefer>
                </alias>

                <!-- System UI: SF Pro -->
                <alias>
                  <family>system-ui</family>
                  <prefer>
                    <family>SF Pro</family>
                    <family>Symbols Nerd Font</family>
                  </prefer>
                </alias>

                <!-- Ensure SF Pro renders with macOS-like settings -->
                <match target="font">
                  <test name="family" compare="eq">
                    <string>SF Pro</string>
                  </test>
                  <edit name="fontfeatures" mode="append">
                    <string>tnum</string>
                    <string>ss01</string>
                  </edit>
                </match>

                <!-- Ensure New York renders with proper settings -->
                <match target="font">
                  <test name="family" compare="eq">
                    <string>New York</string>
                  </test>
                  <edit name="fontfeatures" mode="append">
                    <string>ss01</string>
                  </edit>
                </match>
              </fontconfig>
            '';
          };
          packages =
            (with pkgs; [
              noto-fonts-color-emoji
              noto-fonts-monochrome-emoji
              noto-fonts-cjk-sans
              noto-fonts-cjk-serif
              jetbrains-mono
              nerd-fonts.jetbrains-mono
              font-awesome
              material-icons
              nerd-fonts.symbols-only
              powerline-fonts
            ])
            ++ (with inputs.apple-fonts.packages.${pkgs.system}; [
              sf-pro
              sf-mono
              ny
            ]);
        };
      };
  };
}
